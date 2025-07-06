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
            loadMonthlyTransactions()
        }
    }
    
    
    private(set) var transactions: [Int: [Transaction]] = [:]
    private var dayCache: [Date: [Int?]] = [:]  // 월별 날짜 배열 캐싱
    private let calendar = Calendar.current
    
    init(currentMonth: Date = Date()) {
        self.currentMonth = currentMonth
    }
    
    var monthButtonString: String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy년 M월"
        return dateFormatter.string(from: currentMonth)
    }
    
    func changeMonth(by offset: Int) {
        guard let next = calendar.date(byAdding: .month, value: offset, to: currentMonth) else { return }
        currentMonth = next
    }
    
    func isCurrentMonth(with date: Date) -> Bool {
        return calendar.isDate(date, equalTo: currentMonth, toGranularity: .month)
    }
    
    func generateDayItems() -> [DayItem] {
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
                
                items.append(DayItem(date: date, income: income, expense: expense))
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
                
                items.append(DayItem(date: date, income: 0, expense: 0))
            }
            
        }
        
        return items
    }
    private func loadMonthlyTransactions() {
        let allTx = CoreDataManager.shared
                         .fetchTransactionsForMonth(containing: currentMonth)
        
        transactions = Dictionary(grouping: allTx) { tx in
            Calendar.current.component(.day, from: tx.date)
        }
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
