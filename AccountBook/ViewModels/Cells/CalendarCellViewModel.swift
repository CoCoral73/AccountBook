//
//  DayCellViewModel.swift
//  AccountBook
//
//  Created by 김정원 on 7/4/25.
//

import Foundation

class CalendarCellViewModel {
    
    private var dayItem: DayItem
    private var isCurrentMonth: Bool
    
    var isSelected: Bool = false {
        didSet {
            onSelectionChanged?(isSelected)
        }
    }
    
    var onSelectionChanged: ((Bool) -> Void)?
    
    init(dayItem: DayItem, isCurrentMonth: Bool) {
        self.dayItem = dayItem
        self.isCurrentMonth = isCurrentMonth
    }
    
    var dayStringAndWeekday: (text: String, weekday: Int) {
        let date = dayItem.date
        let cal = Calendar.current
        var weekday = cal.component(.weekday, from: date) // 일=1, 토=7
        
        let dayString = "\(cal.component(.day, from: date))"
        
        if !isCurrentMonth {
            weekday = 0
        }
        
        return (dayString, weekday)
    }
    
    var incomeString: String? {
        return dayItem.income == 0 ? nil : dayItem.income.formattedWithComma
    }
    
    var expenseString: String? {
        return dayItem.expense == 0 ? nil : dayItem.expense.formattedWithComma
    }
    
}
