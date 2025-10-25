//
//  PeriodSelectionViewModel.swift
//  AccountBook
//
//  Created by 김정원 on 10/25/25.
//

import UIKit

class PeriodSelectionViewModel {
    let years = DefaultSetting.years
    let months = DefaultSetting.months
    let calendar = Calendar.current
    let dateFormatter: DateFormatter = {
        let fmt = DateFormatter()
        fmt.dateFormat = "yyyy.MM.dd"
        return fmt
    }()
    
    private var periodType: StatisticPeriod = .monthly
    private var startDate: Date
    private var endDate: Date
    private var selectedDateButtonTag: Int = 0
    
    var onDidChangedDatePicker: (() -> ())?
    
    init(_ currentMonth: Date = Date()) {
        startDate = currentMonth.startOfMonth
        endDate = currentMonth.endOfMonth
    }
    
    var startDateButtonString: String {
        dateFormatter.string(from: startDate)
    }
    var endDateButtonString: String {
        dateFormatter.string(from: endDate)
    }
    var dateButtonEnabled: Bool {
        periodType == .custom
    }
    var isHiddenForPickerView: Bool {
        periodType == .custom
    }
    var isHiddenForDatePicker: Bool {
        periodType != .custom
    }
    var selectedRowForYear: Int {
        let year = calendar.component(.year, from: startDate)
        let index = years.firstIndex(of: year)!
        return index
    }
    var selectedRowForMonth: Int {
        let month = calendar.component(.month, from: startDate)
        let index = months.firstIndex(of: month)!
        return index
    }
    
    func setPeriodType(_ value: Int) {
        periodType = StatisticPeriod(rawValue: value)!
    }
    
    func handleDateButton(_ tag: Int) -> Date {
        selectedDateButtonTag = tag
        return selectedDateButtonTag == 0 ? startDate : endDate
    }
    
    func handleDatePicker(_ date: Date) {
        if selectedDateButtonTag == 0 {
            startDate = calendar.startOfDay(for: date)
        } else {
            endDate = calendar.startOfDay(for: date)
        }
        
        onDidChangedDatePicker?()
    }
}
