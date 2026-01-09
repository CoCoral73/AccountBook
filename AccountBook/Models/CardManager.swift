//
//  CardManager.swift
//  AccountBook
//
//  Created by 김정원 on 12/11/25.
//
import Foundation

class CardManager {
    static let shared = CardManager()
    private init() { }
    
    private var calendar = Calendar.current
    
    func calculateCurrentMonthAmountForDebitCard(for card: DebitCardItem, now: Date = Date()) -> Int64 {
        let startDate = now.startOfMonth, endDate = now.startOfNextMonth
        guard let txs = card.transactions as? Set<Transaction> else { return 0 }
        
        var total: Int64 = 0
        for tx in txs where tx.date >= startDate && tx.date < endDate {
            total += tx.amount
        }
        
        return total
    }
    
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
    
    func getWithdrawalDate(withdrawalDay: Int16, baseDate: Date = Date()) -> Date {
        let comps = calendar.dateComponents([.year, .month, .day], from: baseDate)
        var withdrawalDate = calendar.safeDate(year: comps.year!, month: comps.month!, day: Int(withdrawalDay))!
        
        if comps.day! <= Int(withdrawalDay) {
            return withdrawalDate
        }
        
        withdrawalDate = calendar.date(byAdding: .month, value: 1, to: withdrawalDate)!
        return withdrawalDate
    }
    
    func calculateCurrentMonthCycle(for card: CreditCardItem, now: Date = Date()) -> (startDate: Date, endDate: Date)? {
        let startDay = Int(card.startDay)
        if startDay == 1 {
            return (now.startOfMonth, now.startOfNextMonth)
        }
        
        let endDay = startDay - 1
        let components = calendar.dateComponents([.year, .month, .day], from: now)
        guard let year = components.year, let month = components.month, let day = components.day else { return nil }
        
        let startYear: Int, startMonth: Int, endYear: Int, endMonth: Int
        let startDate: Date, endDate: Date
        if day >= startDay {
            startYear = year
            startMonth = month
            startDate = calendar.safeDate(year: startYear, month: startMonth, day: startDay)!
            
            if month == 12 {
                endYear = year + 1
                endMonth = 1
            } else {
                endYear = year
                endMonth = month + 1
            }
            
            endDate = calendar.safeDate(year: endYear, month: endMonth, day: endDay)!.startOfNextDay
        } else {
            if month == 1 {
                startYear = year - 1
                startMonth = 12
            } else {
                startYear = year
                startMonth = month - 1
            }
            
            startDate = calendar.safeDate(year: startYear, month: startMonth, day: startDay)!
            
            endYear = year
            endMonth = month
            
            endDate = calendar.safeDate(year: endYear, month: endMonth, day: endDay)!.startOfNextDay
        }
        
        return (startDate, endDate)
    }
    
    func calculateSpecificMonthCycle(for card: CreditCardItem, withdrawalDate: Date) -> (startDate: Date, endDate: Date)? {
        let (startDay, withdrawalDay) = (Int(card.startDay), Int(card.withdrawalDay))
        let lastMonth = calendar.date(byAdding: .month, value: -1, to: withdrawalDate)!
        
        if startDay == 1 {
            return (lastMonth.startOfMonth, lastMonth.startOfNextMonth)
        }
        
        let endDay = startDay - 1
        let startDate: Date, endDate: Date
        if withdrawalDay <= endDay {
            let theMonthBeforeLast = calendar.date(byAdding: .month, value: -2, to: withdrawalDate)!
            let comps = calendar.dateComponents([.year, .month], from: theMonthBeforeLast)
            guard let year = comps.year, let month = comps.month else { return nil }
            startDate = calendar.startOfDay(for: calendar.safeDate(year: year, month: month, day: startDay)!)
            
            let comps2 = calendar.dateComponents([.year, .month], from: lastMonth)
            guard let year2 = comps2.year, let month2 = comps2.month else { return nil }
            endDate = calendar.safeDate(year: year2, month: month2, day: endDay)!.startOfNextDay
        } else {
            let comp = calendar.dateComponents([.year, .month], from: lastMonth)
            guard let year = comp.year, let month = comp.month else { return nil }
            startDate = calendar.startOfDay(for: calendar.safeDate(year: year, month: month, day: startDay)!)
            
            let comp2 = calendar.dateComponents([.year, .month], from: withdrawalDate)
            guard let year2 = comp2.year, let month2 = comp2.month else { return nil }
            endDate = calendar.safeDate(year: year2, month: month2, day: endDay)!.startOfNextDay
        }
        
        return (startDate, endDate)
    }
    
    //(총 금액, 미결제 금액) 반환
    func calculateCycleSpending(for card: CreditCardItem, cycle: (startDate: Date, endDate: Date)) -> Int64 {
        guard let txs = card.transactions as? Set<Transaction> else { return 0 }
        
        var total: Int64 = 0
        for tx in txs where tx.date >= cycle.startDate && tx.date < cycle.endDate {
            //전제: amount > 0
            total += tx.amount
        }
        
        return total
    }
    
    func calculateOutstandingCycleSpending(for card: CreditCardItem, cycle: (startDate: Date, endDate: Date)) -> Int64 {
        guard let txs = card.transactions as? Set<Transaction> else { return 0 }
        
        var outstanding: Int64 = 0
        for tx in txs where tx.date >= cycle.startDate && tx.date < cycle.endDate {
            if !tx.isCompleted {
                outstanding += tx.amount
            }
        }
        
        return outstanding
    }
    
    func completeSpecificCycle(for card: CreditCardItem, cycle: (startDate: Date, endDate: Date)) {
        guard let txs = card.transactions as? Set<Transaction> else { return }
        
        for tx in txs where tx.date >= cycle.startDate && tx.date < cycle.endDate {
            TransactionManager.shared.completeTransaction(tx, shouldSave: false)
        }
        
        CoreDataManager.shared.saveContext()
    }
    
    func cancelSpecificCycle(for card: CreditCardItem, cycle: (startDate: Date, endDate: Date)) {
        guard let txs = card.transactions as? Set<Transaction> else { return }
        
        for tx in txs where tx.date >= cycle.startDate && tx.date < cycle.endDate {
            TransactionManager.shared.cancelTransaction(tx, shouldSave: false)
        }
        
        CoreDataManager.shared.saveContext()
    }
}
