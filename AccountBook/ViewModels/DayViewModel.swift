//
//  DayCellViewModel.swift
//  AccountBook
//
//  Created by 김정원 on 7/4/25.
//

import UIKit

class DayViewModel {
    
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
    
    var dayStringAndColor: (text: String, color: UIColor) {
        let date = dayItem.date
        let cal = Calendar.current
        let weekday = cal.component(.weekday, from: date) // 일=1, 토=7
        
        let dayString = "\(cal.component(.day, from: date))"
        let dayColor: UIColor
        
        if !isCurrentMonth {
            dayColor = .systemGray
        } else {
            switch weekday {
            case 1: dayColor = .systemRed
            case 7: dayColor = .systemBlue
            default: dayColor = .label
            }
        }
        
        return (dayString, dayColor)
    }
    
    var incomeString: String? {
        return dayItem.income == 0 ? nil : "\(dayItem.income)"
    }
    var incomeTextColor: UIColor {
        return .systemGreen
    }
    
    var expenseString: String? {
        return dayItem.expense == 0 ? nil : "\(dayItem.expense)"
    }
    var expenseTextColor: UIColor {
        return .systemOrange
    }
    
}
