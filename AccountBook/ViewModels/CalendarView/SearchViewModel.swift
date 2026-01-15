//
//  SearchViewModel.swift
//  AccountBook
//
//  Created by 김정원 on 1/12/26.
//

import Foundation

class SearchViewModel {
    var allTxs: [Transaction]
    var filteredTxs: [Transaction]
    
    var keyword: String?
    
    var isEntire: Bool = true
    var periodType: PeriodType?
    var startDate: Date = DefaultSetting.firstDate
    var endDate: Date = DefaultSetting.lastDate
    
    var minAmount: Decimal = 0
    var maxAmount: Decimal = Decimal(Int64.max)
    
    init() {
        allTxs = CoreDataManager.shared.fetchTransactions()
        filteredTxs = allTxs
    }
    
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
    var numberOfRowsInSection: Int {
        return filteredTxs.count
    }
    
    func currentAmount(tag: Int) -> Decimal {
        if tag == 0 { return minAmount }
        else {
            return maxAmount == Decimal(Int64.max) ? 0 : maxAmount
        }
    }
    
    func currentAmountDisplay(tag: Int) -> String {
        if tag == 0 && minAmount == 0 { return "최소" }
        else if tag == 1 && maxAmount == Decimal(Int64.max) { return "최대" }
        
        let value = tag == 0 ? minAmount : maxAmount
        let formatted = NSDecimalNumber(decimal: value).int64Value.formattedWithComma + "원"
        return formatted
    }
    
    func cellForRowAt(_ index: Int) -> SearchCellViewModel {
        let tx = filteredTxs[index]
        return SearchCellViewModel(transaction: tx)
    }
    
    func didSelectRowAt(_ index: Int) -> TransactionDetailViewModel {
        let tx = filteredTxs[index]
        return TransactionDetailViewModel(transaction: tx)
    }
    
    func setKeyword(with keyword: String?) {
        self.keyword = keyword
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
    
    func handleNumericKeypad(_ value: Decimal, tag: Int) {
        if tag == 0 {
            minAmount = value
        } else {
            maxAmount = value == 0 ? Decimal(Int64.max) : value
        }
    }
}
