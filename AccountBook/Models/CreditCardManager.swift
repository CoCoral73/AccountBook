//
//  CreditCardManager.swift
//  AccountBook
//
//  Created by 김정원 on 12/11/25.
//
import Foundation

class CreditCardManager {
    static let shared = CreditCardManager()
    private init() { }
    
    private var calendar = Calendar.current
    
    func getPeriodString(withdrawalDay: Int16, startDay: Int16) -> String {
        let periodString: String
        
        if startDay == 1 {
            periodString = "전월 1일 ~ 전월 말일"
        } else {
            let endDay = startDay - 1
            if withdrawalDay <= endDay {
                periodString = "전전월 \(startDay)일 ~ 전월 \(endDay)일"
            } else {
                periodString = "전월 \(startDay)일 ~ 당월 \(endDay)일"
            }
        }
        
        return periodString
    }
    
    func calculateCurrentMonthCycle(startDay: Int, now: Date = Date()) -> (startDate: Date, endDate: Date)? {
        if startDay == 1 {
            return (now.startOfMonth, now.endOfMonth)
        }
        
        let endDay = startDay - 1
        let components = calendar.dateComponents([.year, .month, .day], from: now)
        guard let year = components.year, let month = components.month, let day = components.day else { return nil }
        
        let startYear: Int, startMonth: Int, endYear: Int, endMonth: Int
        let startDate: Date, endDate: Date
        if day >= startDay {
            startYear = year
            startMonth = month
            startDate = calendar.date(year: startYear, month: startMonth, day: startDay)!
            
            if month == 12 {
                endYear = year + 1
                endMonth = 1
            } else {
                endYear = year
                endMonth = month + 1
            }
            
            endDate = calendar.date(year: endYear, month: endMonth, day: endDay)!.endOfDay
        } else {
            if month == 1 {
                startYear = year - 1
                startMonth = 12
            } else {
                startYear = year
                startMonth = month - 1
            }
            
            startDate = calendar.date(year: startYear, month: startMonth, day: startDay)!
            
            endYear = year
            endMonth = month
            
            endDate = calendar.date(year: endYear, month: endMonth, day: endDay)!.endOfDay
        }
        
        return (startDate, endDate)
    }
    
    //(총 금액, 미결제 금액) 반환
    func calculateCycleSpending(for card: CreditCardItem, cycle: (startDate: Date, endDate: Date)) -> (Int64, Int64) {
        guard let txs = card.transactions as? Set<Transaction> else { return (0, 0) }
        
        var total: Int64 = 0, outstanding: Int64 = 0
        for tx in txs {
            if tx.date >= cycle.startDate && tx.date <= cycle.endDate {
                //전제: amount > 0
                total += tx.amount
                outstanding += tx.isCompleted ? 0 : tx.amount
            }
        }
        
        return (total, outstanding)
    }
}
