//
//  PeriodSelectionViewModel.swift
//  AccountBook
//
//  Created by 김정원 on 10/25/25.
//

import Foundation

class PeriodSelectionViewModel {
    let years = DefaultSetting.years
    let months = DefaultSetting.months
    let calendar = Calendar.current
    let dateFormatter: DateFormatter = {
        let fmt = DateFormatter()
        fmt.dateFormat = "yyyy.MM.dd"
        return fmt
    }()
    
    private var periodType: StatisticPeriod
    private var startDate: Date
    private var endDate: Date
    private var selectedDateButtonTag: Int = 0
    
    var onDidChangeDate: (() -> ())?
    var onDidApplyPeriod: ((StatisticPeriod, Date, Date) -> ())?
    
    init(_ periodType: StatisticPeriod, _ startDate: Date, _ endDate: Date) {
        self.periodType = periodType
        
        switch periodType {
        case .monthly:
            self.startDate = startDate.startOfMonth
            self.endDate = startDate.startOfNextMonth
        case .yearly:
            self.startDate = startDate.startOfYear
            self.endDate = startDate.endOfYear
        case .custom:
            self.startDate = startDate
            self.endDate = endDate
        }
    }
    
    var initialSegmentIndex: Int {
        periodType.rawValue
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
    var numberOfComponents: Int {
        periodType == .monthly ? 2 : 1
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
        
        let (year, month) = (calendar.component(.year, from: startDate), calendar.component(.month, from: startDate))
        updatePeriodDates(year: year, month: month)
    }
    
    func handleDateButton(_ tag: Int) -> Date {
        selectedDateButtonTag = tag
        return selectedDateButtonTag == 0 ? startDate : endDate
    }
    
    func handleSelectRow(component: Int, row: Int) {
        var year = calendar.component(.year, from: startDate), month = calendar.component(.month, from: startDate)

        if component == 0 { //year
            year = years[row]
        } else {    //month
            month = months[row]
        }
        
        updatePeriodDates(year: year, month: month)
    }
    
    func updatePeriodDates(year: Int, month: Int) {
        let (year, month) = (year, periodType == .yearly ? 1 : month)
        let startComp = DateComponents(year: year, month: month, day: 1)
        
        guard let startDate = calendar.date(from: startComp) else {
            fatalError("PeriodSelectionViewModel: startComp -> Date 변환 실패")
        }
        
        let endDate: Date
        switch periodType {
        case .monthly:
            endDate = startDate.startOfNextMonth
        case .yearly:
            endDate = startDate.endOfYear
        case .custom:
            return
        }
        
        self.startDate = startDate
        self.endDate = endDate
        
        onDidChangeDate?()
    }
    
    func handleDatePicker(_ date: Date) {
        if selectedDateButtonTag == 0 {
            startDate = calendar.startOfDay(for: date)
        } else {
            endDate = calendar.startOfDay(for: date)
        }
        
        onDidChangeDate?()
    }
    
    func handleApplyButton() {
        onDidApplyPeriod?(periodType, startDate, endDate)
    }
}
