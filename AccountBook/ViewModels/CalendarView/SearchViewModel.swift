//
//  SearchViewModel.swift
//  AccountBook
//
//  Created by 김정원 on 1/12/26.
//

import Foundation

class SearchViewModel {
    var isEntire: Bool = true
    var periodType: PeriodType?
    var startDate: Date = DefaultSetting.firstDate
    var endDate: Date = DefaultSetting.lastDate
    
    var onDidSetPeriod: (() -> Void)?
    
    var isPeriodSelectButtonHidden: Bool {
        return isEntire
    }
    var periodTypeDisplay: String {
        return isEntire ? "전체" : "지정"
    }
    var periodDisplay: String {
        let fmt = DateFormatter()
        fmt.dateFormat = "yyyy.MM.dd"
        return "\(fmt.string(from: startDate)) ~ \(fmt.string(from: endDate.yesterday))"
    }
    
    func handlePeriodButton(isEntire: Bool) {
        self.isEntire = isEntire
        
        if isEntire {
            periodType = nil
            startDate = DefaultSetting.firstDate
            endDate = DefaultSetting.lastDate
        } else {
            periodType = .monthly
            let now = Date()
            startDate = now.startOfMonth
            endDate = now.startOfNextMonth
        }
        onDidSetPeriod?()
    }
    
    func handlePeriodSelectButton() -> PeriodSelectionViewModel {
        let vm = PeriodSelectionViewModel(periodType!, startDate, endDate)
        vm.onDidApplyPeriod = { [weak self] type, startDate, endDate in
            guard let self = self else { return }
            self.periodType = type
            self.startDate = startDate
            self.endDate = endDate
            self.onDidSetPeriod?()
        }
        return vm
    }
}
