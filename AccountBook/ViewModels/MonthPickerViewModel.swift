//
//  DatePickerViewModel.swift
//  AccountBook
//
//  Created by 김정원 on 7/7/25.
//

import Foundation

class MonthPickerViewModel {
    let years = DefaultSetting.years
    let months = DefaultSetting.months
    
    private(set) var selectedYear: Int
    private(set) var selectedMonth: Int
    
    private let calendar = Calendar.current
    
    var onDidSelect: ((Date) -> Void)?
    
    init(startDate: Date) {
        selectedYear = calendar.component(.year, from: startDate)
        selectedMonth = calendar.component(.month, from: startDate)
    }
    
    var selectedYearIndex: Int {
        return years.firstIndex(of: selectedYear)!
    }
    var selectedMonthIndex: Int {
        return months.firstIndex(of: selectedMonth)!
    }
    
    func handleTodayButton() {
        let now = Date()
        selectedYear = calendar.component(.year, from: now)
        selectedMonth = calendar.component(.month, from: now)
    }
    
    func handleSelectButton(year: Int, month: Int) {
        selectedYear = years[year]
        selectedMonth = months[month]
        
        guard let date = calendar.date(year: selectedYear, month: selectedMonth) else {
            print("MonthPickerViewModel: date 생성 실패")
            return
        }
        //캘린더 뷰컨트롤러에 selectedYear, selectedMonth 전달
        onDidSelect?(date)
    }
}
