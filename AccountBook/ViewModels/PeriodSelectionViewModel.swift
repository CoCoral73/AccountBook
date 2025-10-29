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
    
    var onDidChangeDate: (() -> ())?
    
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
        
        guard let start = calendar.date(from: startComp) else {
            fatalError("PeriodSelectionViewModel: startComp -> Date 변환 실패")
        }
        
        let end: Date
        switch periodType {
        case .monthly:
            end = start.endOfMonth
        case .yearly:
            guard let startOfNextYear = calendar.date(byAdding: .year, value: 1, to: start),
                  let endOfYear = calendar.date(byAdding: .second, value: -1, to: startOfNextYear)
            else { fatalError("PeriodSelectionViewModel: 연말 Date 계산 실패") }
            end = endOfYear
        case .custom:
            return
        }
        
        startDate = start
        endDate = end
        
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
    }
}
