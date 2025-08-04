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
    
    private(set) var dayItemsForCurrentMonth: [DayItem] = []
    private(set) var transactions: [Int: [Transaction]] = [:]  //현재 달이 아닌 날짜는 포함 안됨
    private var dayCache: [Date: [Int?]] = [:]  // 월별 날짜 배열 캐싱
    private let calendar = Calendar.current
    
    private(set) var selectedDate: Date
    private(set) var selectedDay: Int
    
    init(currentMonth: Date = Date()) {
        self.currentMonth = currentMonth
        selectedDate = currentMonth
        selectedDay = calendar.component(.day, from: currentMonth)
        
        loadTransactions()
        generateDayItems()
    }
    
    var monthButtonString: String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy년 M월"
        return dateFormatter.string(from: currentMonth)
    }
    
    var numberOfRowsInSection: Int {
        guard let count = transactions[selectedDay]?.count else { return 0 }
        return count
    }
    
    var cellForRowAt: [Transaction] {
        guard let datas = transactions[selectedDay] else { return [] }
        return datas
    }
    
    func changeMonth(by offset: Int) {
        guard let next = calendar.date(byAdding: .month, value: offset, to: currentMonth) else { return }
        currentMonth = next
    }
    
    func isCurrentMonth(with date: Date) -> Bool {
        return calendar.isDate(date, equalTo: currentMonth, toGranularity: .month)
    }
    
    func setSelectedDay(with index: Int) -> DayItem {
        let date = dayItemsForCurrentMonth[index].date
        selectedDate = date
        currentMonth = selectedDate
        selectedDay = calendar.component(.day, from: selectedDate)
        return dayItemsForCurrentMonth.first { item in
            calendar.isDate(item.date, inSameDayAs: date)
        }!
    }
    
    func updateDayItem(for date: Date, income: Int64, expense: Int64) -> Int? {
        guard let index = dayItemsForCurrentMonth.firstIndex(where: { Calendar.current.isDate($0.date, inSameDayAs: date) }) else {
            return nil
        }

        var item = dayItemsForCurrentMonth[index]
        item = DayItem(index: index, date: date, income: item.income + income, expense: item.expense + expense)
        dayItemsForCurrentMonth[index] = item
        return index
    }
    
    func handleMonthButton(storyboard: UIStoryboard?, fromVC: UIViewController) {
        guard let pickerVC = storyboard?
            .instantiateViewController(identifier: "MonthPickerViewController", creator: { coder in
                MonthPickerViewController(coder: coder, viewModel: MonthPickerViewModel(startDate: self.currentMonth)) })
        else {
            fatalError("MonthPickerViewController 생성 에러")
        }
        
        pickerVC.viewModel.onDidSelect = { [weak self] date in
            guard let self = self else { return }
            
            self.currentMonth = date
            (fromVC as! CalendarViewController).applySnapshot()
        }
        
        pickerVC.modalPresentationStyle = .custom
        pickerVC.transitioningDelegate = fromVC as! CalendarViewController
        fromVC.present(pickerVC, animated: true, completion: nil)
    }
    
    func handleAddTransactionButton(type: String, storyboard: UIStoryboard?, fromVC: UIViewController) {
        guard let addVC = storyboard?.instantiateViewController(identifier: "AddViewController", creator: { coder in
            AddViewController(coder: coder, viewModel: AddViewModel(currentDate: self.selectedDate, isIncome: type == "수입")) })
        else {
            fatalError("AddViewController 생성 에러")
        }
        
        addVC.viewModel.onDidAddTransaction = { [weak self] transaction in
            guard let self = self else { return }
            self.loadTransactions(with: transaction.date)
            (fromVC as! CalendarViewController).reloadDayItem(transaction)
        }
        addVC.modalPresentationStyle = .fullScreen
        fromVC.present(addVC, animated: true)
    }
    
    private func generateDayItems() {
        let rawDays = days(for: currentMonth)      // [Int?]
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
                
                items.append(DayItem(index: i, date: date, income: income, expense: expense))
            } else {
                let date: Date, diff: Int
                if i < firstIndex {
                    diff = i - firstIndex
                    date = calendar.date(byAdding: .day, value: diff, to: firstOfMonth)!
                }
                else {
                    diff = i - lastIndex - 1
                    let firstOfNextMonth = calendar.date(byAdding: .month, value: 1, to: firstOfMonth)!
                    date = calendar.date(byAdding: .day, value: diff, to: firstOfNextMonth)!
                }
                
                items.append(DayItem(index: i, date: date, income: 0, expense: 0))
            }
            
        }
        
        dayItemsForCurrentMonth = items
    }
    
    private func loadTransactions() {
        let allTx = CoreDataManager.shared.fetchTransactions(containing: currentMonth)
        
        transactions = Dictionary(grouping: allTx) { tx in
            Calendar.current.component(.day, from: tx.date)
        }
    }
    
    private func loadTransactions(with date: Date) {
        let tx = CoreDataManager.shared.fetchTransactions(with: date)
        dump(tx)
        let day = calendar.component(.day, from: date)
        transactions[day] = tx
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
