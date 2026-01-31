//
//  CalendarViewModel.swift
//  AccountBook
//
//  Created by 김정원 on 7/5/25.
//

import Foundation

class CalendarViewModel {
    
    private var currentMonth: Date {
        didSet {
            loadTransactions()
            generateDayItems()
            onDidSetCurrentMonth?()
        }
    }
    
    var onDidSetCurrentMonth: (() -> Void)?
    var onRequestUpdateDayItems: (() -> Void)?
    var onRequestSelectDayItem: ((IndexPath) -> Void)?
    
    private(set) var itemIDsByDate: [Date: UUID] = [:]
    private(set) var dayItemsByUUID: [UUID: DayItem] = [:]
    private(set) var transactions: [Int: [Transaction]] = [:]  //현재 달이 아닌 날짜는 포함 안됨
    private var dayCache: [Date: [Int?]] = [:]  // 월별 날짜 배열 캐싱
    private let calendar = Calendar.current
    
    private(set) var selectedDate: Date
    private(set) var selectedDay: Int
    
    init(now: Date = Date()) {
        self.currentMonth = now
        selectedDate = calendar.startOfDay(for: now)
        selectedDay = calendar.component(.day, from: now)
        
        loadTransactions()
        generateDayItems()
    }
    
    var monthButtonString: String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy년 M월 "
        return dateFormatter.string(from: currentMonth)
    }
    
    private(set) var totals: (income: Int64, expense: Int64, total: Int64) = (0, 0, 0)
    
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
        guard isCurrentMonth(with: selectedDate) ,let count = transactions[selectedDay]?.count else { return 0 }
        return count
    }
    
    var snapshotItems: [UUID] {
        let sortedDates = itemIDsByDate.keys.sorted()   //날짜 오름차순 정렬
        let sortedUUIDs = sortedDates.compactMap { itemIDsByDate[$0] }  //날짜 순서대로 UUID
        return sortedUUIDs
    }
    
    func txDidUpdate(_ date: Date) {
        if isCurrentMonth(with: date) {
            loadTransactions()
            updateDayItems()
            setSelectedDate(with: date)
            onRequestUpdateDayItems?()
        } else {
            setSelectedDate(with: date)
            currentMonth = date
        }
    }
    
    func cellForRowAt(_ index: Int) -> Transaction {
        guard let datas = transactions[selectedDay] else {
            fatalError("Calendar View Model: transactions 조회 실패")
        }
        return datas[index]
    }
    
    func changeMonth(by offset: Int) {
        guard let next = calendar.date(byAdding: .month, value: offset, to: currentMonth) else { return }
        currentMonth = next
    }
    
    func isCurrentMonth(with date: Date) -> Bool {
        return calendar.isDate(date, equalTo: currentMonth, toGranularity: .month)
    }
    
    //뷰모델에서
    func setSelectedDate(with date: Date) {
        selectedDate = date
        selectedDay = calendar.component(.day, from: selectedDate)
    }
    
    //뷰컨트롤러에서
    func setSelectedDate(at indexPath: IndexPath, id: UUID) {
        guard let item = dayItemsByUUID[id] else { return }
        
        setSelectedDate(with: item.date)
        
        if isCurrentMonth(with: item.date) {
            onRequestSelectDayItem?(indexPath)
        } else {
            currentMonth = selectedDate
        }
    }
    
    func shouldSelectDate() -> UUID? {
        if isCurrentMonth(with: selectedDate) {
            return itemIDsByDate[selectedDate]!
        }
        return nil
    }
    
    func handleMonthButton() -> MonthPickerViewModel {
        let vm = MonthPickerViewModel(startDate: currentMonth)
        vm.onDidSelect = { [weak self] date in
            guard let self = self else { return }
            
            currentMonth = date
            onDidSetCurrentMonth?()
        }
        return vm
    }
    
    func handleSearchButton() -> SearchViewModel {
        return SearchViewModel()
    }
    
    func handleAddTransactionButton(tag: Int) -> TransactionAddViewModel {
        return TransactionAddViewModel(date: selectedDate, type: TransactionType(rawValue: Int16(tag))!)
    }
    
    private func updateDayItems() {
        var date = currentMonth.startOfMonth
        while date < currentMonth.startOfNextMonth {
            let uuid = itemIDsByDate[date]!
            var item = dayItemsByUUID[uuid]!
            let day = calendar.component(.day, from: date)
            
            let income = transactions[day]?.reduce(0, { result, ta in
                return result + (ta.type == .income ? ta.amount : 0)
            }) ?? 0
            let expense = transactions[day]?.reduce(0, { result, ta in
                return result + (ta.type == .expense ? ta.amount : 0)
            }) ?? 0
            
            item.income = income
            item.expense = expense
            dayItemsByUUID[uuid] = item
            
            date = calendar.date(byAdding: .day, value: 1, to: date)!
        }
    }
    
    private func generateDayItems() {
        let rawDays = days(for: currentMonth)   // [Int?] ex) [nil, nil, 1, 2, 3, ..., 31, nil]
        // 이번 달 1일 Date 계산
        let startOfMonth = currentMonth.startOfMonth
        
        let firstIndex = rawDays.firstIndex(where: { $0 != nil })!    //이번 달 1일
        let lastIndex = rawDays.lastIndex(where: { $0 != nil })!    //이번 달 말일
        
        var items: [DayItem] = []
        for i in 0..<rawDays.count {
            if let day = rawDays[i] {
                let date = calendar.date(byAdding: .day, value: day-1, to: startOfMonth)!
                
                let income = transactions[day]?.reduce(0, { result, ta in
                    return result + (ta.type == .income ? ta.amount : 0)
                }) ?? 0
                let expense = transactions[day]?.reduce(0, { result, ta in
                    return result + (ta.type == .expense ? ta.amount : 0)
                }) ?? 0
                
                items.append(DayItem(id: UUID(), date: date, income: income, expense: expense))
            } else {    //out-of-month 날짜 처리
                let date: Date, diff: Int
                if i < firstIndex { //이전 달
                    diff = i - firstIndex
                    date = calendar.date(byAdding: .day, value: diff, to: startOfMonth)!
                }
                else {  //다음 달
                    diff = i - lastIndex - 1
                    let startOfNextMonth = startOfMonth.startOfNextMonth
                    date = calendar.date(byAdding: .day, value: diff, to: startOfNextMonth)!
                }
                
                items.append(DayItem(id: UUID(), date: date, income: 0, expense: 0))
            }
            
        }
        
        itemIDsByDate = Dictionary(uniqueKeysWithValues: items.map { ($0.date, $0.id) })
        dayItemsByUUID = Dictionary(uniqueKeysWithValues: items.map { ($0.id, $0) })
    }
    
    func loadTransactions() {
        let allTx = CoreDataManager.shared.fetchTransactions(forMonth: currentMonth)
        
        transactions = Dictionary(grouping: allTx) { tx in
            Calendar.current.component(.day, from: tx.date)
        }
        calculateTotals()
    }
    
    private func calculateTotals() {
        let (income, expense) = transactions.values.flatMap { $0 }.reduce(into: (Int64(0), Int64(0))) { acc, tx in
            if tx.type == .income { acc.0 += tx.amount }
            else if tx.type == .expense { acc.1 += tx.amount }
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
