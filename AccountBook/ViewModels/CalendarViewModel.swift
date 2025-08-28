//
//  CalendarViewModel.swift
//  AccountBook
//
//  Created by 김정원 on 7/5/25.
//

import UIKit

class CalendarViewModel {
    
    private var currentMonth: Date {
        didSet {
            loadTransactions()
            generateDayItems()
            onDidSetCurrentMonth?()
        }
    }
    
    var onDidSetCurrentMonth: (() -> Void)?
    
    private(set) var itemIDsByDate: [Date: UUID] = [:]
    private(set) var dayItemsByUUID: [UUID: DayItem] = [:]
    private(set) var transactions: [Int: [Transaction]] = [:]  //현재 달이 아닌 날짜는 포함 안됨
    private var dayCache: [Date: [Int?]] = [:]  // 월별 날짜 배열 캐싱
    private let calendar = Calendar.current
    
    private(set) var selectedDate: Date
    private(set) var selectedDay: Int
    
    init(currentMonth: Date = Date()) {
        self.currentMonth = currentMonth
        selectedDate = calendar.startOfDay(for: currentMonth)
        selectedDay = calendar.component(.day, from: currentMonth)
        
        loadTransactions()
        generateDayItems()
    }
    
    var monthButtonString: String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy년 M월"
        return dateFormatter.string(from: currentMonth)
    }
    
    private var totals: (income: Int64, expense: Int64, total: Int64) = (0, 0, 0)
    
    var totalIncomeString: String {
        return totals.income.formattedWithComma + "원"
    }
    var totalExpenseString: String {
        return totals.expense.formattedWithComma + "원"
    }
    var totalString: String {
        return totals.total.formattedWithComma + "원"
    }
    var totalStateString: String {
        switch totals.total {
        case ..<0 : return "적자"
        case 0 : return "균형"
        default: return "흑자"
        }
    }
    
    var numberOfRowsInSection: Int {
        guard let count = transactions[selectedDay]?.count else { return 0 }
        return count
    }
    
    var cellForRowAt: [Transaction] {
        guard let datas = transactions[selectedDay] else { return [] }
        return datas
    }
    
    var snapshotItems: [UUID] {
        let sortedDates = itemIDsByDate.keys.sorted()   //날짜 오름차순 정렬
        let sortedUUIDs = sortedDates.compactMap { itemIDsByDate[$0] }  //날짜 순서대로 UUID
        return sortedUUIDs
    }
    
    func changeMonth(by offset: Int) {
        guard let next = calendar.date(byAdding: .month, value: offset, to: currentMonth) else { return }
        currentMonth = next
    }
    
    func isCurrentMonth(with date: Date) -> Bool {
        return calendar.isDate(date, equalTo: currentMonth, toGranularity: .month)
    }
    
    func setSelectedDate(with id: UUID) -> UUID? {
        guard let item = dayItemsByUUID[id] else { return nil }
        selectedDate = calendar.startOfDay(for: item.date)
        selectedDay = calendar.component(.day, from: selectedDate)
        
        if !isCurrentMonth(with: selectedDate) {    //달이 바뀔 때만 didSet 트리거
            currentMonth = selectedDate
        }
        
        return itemIDsByDate[selectedDate]
    }
    
    func updateDayItem(for id: UUID, with transaction: NewTransactionInfo) {
        guard var item = dayItemsByUUID[id] else { return }

        item.income += transaction.isIncome ? transaction.amount : 0
        item.expense += !transaction.isIncome ? transaction.amount : 0
        dayItemsByUUID[id]! = item
    }
    
    func handleMonthButton(storyboard: UIStoryboard?, fromVC: CalendarViewController) {
        guard let pickerVC = storyboard?
            .instantiateViewController(identifier: "MonthPickerViewController", creator: { coder in
                MonthPickerViewController(coder: coder, viewModel: MonthPickerViewModel(startDate: self.currentMonth)) })
        else {
            fatalError("MonthPickerViewController 생성 에러")
        }
        
        pickerVC.viewModel.onDidSelect = { [weak self] date in
            guard let self = self else { return }
            
            self.currentMonth = date
            fromVC.applySnapshot()
        }
        
        pickerVC.modalPresentationStyle = .custom
        pickerVC.transitioningDelegate = fromVC
        fromVC.present(pickerVC, animated: true, completion: nil)
    }
    
    func handleDidSelectRowAt(viewModel: DetailTransactionViewModel, storyboard: UIStoryboard?, fromVC: CalendarViewController) {
        
        viewModel.onDidUpdateOrRemoveTransaction = { [weak self] info in
            guard let self = self, let id = self.itemIDsByDate[info.date] else {
                print("transaction.date로 UUID 찾기 실패(nil)")
                return
            }
            
            loadTransactions(with: info.date)
            updateDayItem(for: id, with: info)
            fromVC.reloadDayItem(id)
        }
        
        guard let detailVC = storyboard?.instantiateViewController(identifier: "DetailTransactionViewController", creator: { coder in
            DetailTransactionViewController(coder: coder, viewModel: viewModel)
        }) else {
            fatalError("DetailTransactionViewController 생성 에러")
        }
        
        fromVC.navigationController?.pushViewController(detailVC, animated: true)
    }
    
    func handleAddTransactionButton(type: String, storyboard: UIStoryboard?, fromVC: UIViewController) {
        guard let addVC = storyboard?.instantiateViewController(identifier: "AddViewController", creator: { coder in
            AddTransactionViewController(coder: coder, viewModel: AddTransactionViewModel(date: self.selectedDate, isIncome: type == "수입")) })
        else {
            fatalError("AddViewController 생성 에러")
        }
        
        addVC.viewModel.onDidAddTransaction = { [weak self] transaction in
            guard let self = self else { return }
            
            let monthChanged = !self.isCurrentMonth(with: transaction.date)
            if monthChanged {   //거래 추가 뷰 내에서 날짜를 바꿨을 때
                self.currentMonth = transaction.date
            }
            
            guard let id = itemIDsByDate[transaction.date] else {
                print("transaction.date로 UUID 찾기 실패(nil)")
                return
            }
            _ = self.setSelectedDate(with: id)
            
            if !monthChanged {
                self.loadTransactions(with: transaction.date)
                updateDayItem(for: id, with: transaction)
            }
            (fromVC as! CalendarViewController).reloadDayItem(id)
        }
        addVC.modalPresentationStyle = .fullScreen
        fromVC.present(addVC, animated: true)
    }
    
    private func generateDayItems() {
        let rawDays = days(for: currentMonth)   // [Int?]
        // 이번 달 1일 Date 계산
        let comps = calendar.dateComponents([.year, .month], from: currentMonth)
        let firstOfMonth = calendar.date(from: comps)!
        
        let firstIndex = rawDays.firstIndex(where: { $0 != nil })!
        let lastIndex = rawDays.lastIndex(where: { $0 != nil })!
        
        var items: [DayItem] = []
        for i in 0..<rawDays.count {
            if let day = rawDays[i] {
                let date = calendar.date(byAdding: .day, value: day-1, to: firstOfMonth)!
                
                let income = transactions[day]?.reduce(0, { result, ta in
                    return result + (ta.isIncome ? ta.amount : 0)
                }) ?? 0
                let expense = transactions[day]?.reduce(0, { result, ta in
                    return result + (!ta.isIncome ? ta.amount : 0)
                }) ?? 0
                
                items.append(DayItem(id: UUID(), date: date, income: income, expense: expense))
            } else {    //out-of-month 날짜 처리
                let date: Date, diff: Int
                if i < firstIndex { //이전 달
                    diff = i - firstIndex
                    date = calendar.date(byAdding: .day, value: diff, to: firstOfMonth)!
                }
                else {  //다음 달
                    diff = i - lastIndex - 1
                    let firstOfNextMonth = calendar.date(byAdding: .month, value: 1, to: firstOfMonth)!
                    date = calendar.date(byAdding: .day, value: diff, to: firstOfNextMonth)!
                }
                
                items.append(DayItem(id: UUID(), date: date, income: 0, expense: 0))
            }
            
        }
        
        itemIDsByDate = Dictionary(uniqueKeysWithValues: items.map { ($0.date, $0.id) })
        dayItemsByUUID = Dictionary(uniqueKeysWithValues: items.map { ($0.id, $0) })
    }
    
    private func loadTransactions() {
        let allTx = CoreDataManager.shared.fetchTransactions(containing: currentMonth)
        
        transactions = Dictionary(grouping: allTx) { tx in
            Calendar.current.component(.day, from: tx.date)
        }
        calculateTotals()
    }
    
    private func loadTransactions(with date: Date) {
        let tx = CoreDataManager.shared.fetchTransactions(with: date)
        
        let day = calendar.component(.day, from: date)
        transactions[day] = tx
        calculateTotals()
    }
    
    private func calculateTotals() {
        let (income, expense) = transactions.values.flatMap { $0 }.reduce(into: (Int64(0), Int64(0))) { acc, tx in
            if tx.isIncome { acc.0 += tx.amount }
            else { acc.1 += tx.amount }
        }
        
        totals = (income, expense, income - expense)
    }
    
    private func days(for date: Date) -> [Int?] {
        if let cached = dayCache[date] { return cached }
        let comps = calendar.dateComponents([.year, .month], from: date)
        let firstOfMonth = calendar.date(from: comps)!
        let weekday = calendar.component(.weekday, from: firstOfMonth)   // 일=1, 월=2, …
        let daysInMonth = calendar.range(of: .day, in: .month, for: date)!.count

        var arr: [Int?] = Array(repeating: nil, count: weekday - 1)
        arr += (1...daysInMonth).map { Optional($0) }
        while arr.count % 7 != 0 { arr.append(nil) }

        dayCache[date] = arr
        return arr
    }
}
