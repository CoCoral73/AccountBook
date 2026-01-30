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
    
    var isCategorySelected: Bool = true
    var isSelectAllForCategory: Bool = true
    var categoryFilter = Set<Category>(CategoryManager.shared.allCategories.flatMap { $0 })
    var categoryViewModels: [[FilterCellViewModel]] = []
    var isSelectAllForAsset: Bool = true
    var assetFilter = Set<AssetItem>(AssetItemManager.shared.allAssetItems.flatMap { $0 })
    var assetViewModels: [[FilterCellViewModel]] = []
    
    var minAmount: Decimal = 0
    var maxAmount: Decimal = Decimal(Int64.max)
    
    var sortCriteria: Int = 0
    
    init() {
        allTxs = CoreDataManager.shared.fetchTransactions()
        filteredTxs = allTxs
        filteredTxs.sort { $0.date > $1.date }
        
        categoryViewModels = CategoryManager.shared.allCategories.map { array in
            return array.map {
                let vm = FilterCellViewModel(type: .category($0), isCheck: true)
                vm.onDidTapCheckBox = { [weak self] in
                    guard let self = self else { return }
                    self.handlePopUpFiltering()
                }
                return vm
            }
        }
        assetViewModels = AssetItemManager.shared.allAssetItems.map { array in
            return array.map {
                let vm = FilterCellViewModel(type: .asset($0), isCheck: true)
                vm.onDidTapCheckBox = { [weak self] in
                    guard let self = self else { return }
                    self.handlePopUpFiltering()
                }
                return vm
            }
        }
    }
    
    var onDidSetPeriod: (() -> Void)?
    var onRequestPopUp: ((String) -> Void)?
    var onDidPopUpApply: ((_ isCategory: Bool, _ title: String) -> Void)?
    var onRequestChangeSelectAll: ((String) -> Void)?
    var onRequestFilterReloadData: (() -> Void)?
    var onRequestReloadData: (() -> Void)?
    
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
    var popUpViewTitle: String {
        return isCategorySelected ? "카테고리" : "자산"
    }
    var numberOfSections: Int {
        return isCategorySelected ? 3 : 4
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
    
    func numberOfRowsInSection(section: Int) -> Int {
        if isCategorySelected {
            switch section {
            case 0:
                return CategoryManager.shared.incomeCategories.count
            case 1:
                return CategoryManager.shared.expenseCategories.count
            default:
                return CategoryManager.shared.transferCategories.count
            }
        } else {
            switch section {
            case 0:
                return 1
            case 1:
                return AssetItemManager.shared.bankAccount.count
            case 2:
                return AssetItemManager.shared.debitCard.count
            default:
                return AssetItemManager.shared.creditCard.count
            }
        }
    }
    
    func cellForRowAt(_ index: Int) -> SearchCellViewModel {
        let tx = filteredTxs[index]
        return SearchCellViewModel(transaction: tx)
    }
    
    func cellForRowAt(_ indexPath: IndexPath) -> FilterCellViewModel {
        if isCategorySelected {
            return categoryViewModels[indexPath.section][indexPath.row]
        } else {
            return assetViewModels[indexPath.section][indexPath.row]
        }
    }
    
    func didSelectRowAt(_ index: Int) -> TransactionDetailViewModel {
        let tx = filteredTxs[index]
        return TransactionDetailViewModel(transaction: tx)
    }
    
    func titleForHeaderInSection(_ section: Int) -> String {
        if isCategorySelected {
            return TransactionType(rawValue: Int16(section))!.name
        } else {
            return AssetType(rawValue: Int16(section))!.displayName
        }
    }
    
    func setKeyword(with keyword: String?) {
        self.keyword = keyword
        filterTransaction()
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
        filterTransaction()
    }
    
    func handlePeriodSelectButton() -> PeriodSelectionViewModel {
        let vm = PeriodSelectionViewModel(periodType!, startDate, endDate)
        vm.onDidApplyPeriod = { [weak self] type, startDate, endDate in
            guard let self = self else { return }
            self.periodType = type
            self.startDate = startDate
            self.endDate = endDate
            self.onDidSetPeriod?()
            filterTransaction()
        }
        return vm
    }
    
    func handleCategoryButton() {
        isCategorySelected = true
        isSelectAllForCategory = categoryFilter.count == categoryViewModels.flatMap { $0 }.count
        onRequestPopUp?(isSelectAllForCategory ? "checkmark.square.fill" : "square")
    }
    
    func handleAssetButtonTapped() {
        isCategorySelected = false
        isSelectAllForAsset = assetFilter.count == assetViewModels.flatMap { $0 }.count
        onRequestPopUp?(isSelectAllForAsset ? "checkmark.square.fill" : "square")
    }
    
    func handleSelectAllButton() {
        if isCategorySelected {
            isSelectAllForCategory.toggle()
            categoryViewModels.flatMap { $0 }.forEach {
                $0.isCheck = isSelectAllForCategory
            }
            onRequestChangeSelectAll?(isSelectAllForCategory ? "checkmark.square.fill" : "square")
        } else {
            isSelectAllForAsset.toggle()
            assetViewModels.flatMap { $0 }.forEach {
                $0.isCheck = isSelectAllForAsset
            }
            onRequestChangeSelectAll?(isSelectAllForAsset ? "checkmark.square.fill" : "square")
        }
        
        onRequestFilterReloadData?()
    }
    
    func handlePopUpFiltering() {
        let isSelectAll: Bool
        if isCategorySelected {
            isSelectAll = categoryViewModels.flatMap { $0 }.filter { $0.isCheck }.count == categoryViewModels.flatMap { $0 }.count
        } else {
            isSelectAll = assetViewModels.flatMap { $0 }.filter { $0.isCheck }.count == assetViewModels.flatMap { $0 }.count
        }
        onRequestChangeSelectAll?(isSelectAll ? "checkmark.square.fill" : "square")
    }
    
    func handlePopUpCancel() {
        if isCategorySelected {
            categoryViewModels.forEach { [weak self] vms in
                guard let self = self else { return }
                vms.forEach { vm in
                    if case let FilterType.category(category) = vm.type {
                        vm.isCheck = self.categoryFilter.contains(category)
                    }
                }
            }
        } else {
            assetViewModels.forEach { [weak self] vms in
                guard let self = self else { return }
                vms.forEach { vm in
                    if case let FilterType.asset(asset) = vm.type {
                        vm.isCheck = self.assetFilter.contains(asset)
                    }
                }
            }
        }
    }
    
    func handlePopUpApply() {
        if isCategorySelected {
            categoryViewModels.forEach { [weak self] vms in
                guard let self = self else { return }
                vms.forEach { vm in
                    if case let FilterType.category(category) = vm.type {
                        if vm.isCheck {
                            self.categoryFilter.insert(category)
                        } else {
                            self.categoryFilter.remove(category)
                        }
                    }
                }
            }
        } else {
            assetViewModels.forEach { [weak self] vms in
                guard let self = self else { return }
                vms.forEach { vm in
                    if case let FilterType.asset(asset) = vm.type {
                        if vm.isCheck {
                            self.assetFilter.insert(asset)
                        } else {
                            self.assetFilter.remove(asset)
                        }
                    }
                }
            }
        }
        
        filterTransaction()
        
        if isCategorySelected {
            let title = categoryFilter.count == categoryViewModels.flatMap { $0 }.count ? "전체" : "선택"
            onDidPopUpApply?(true, title)
        } else {
            let title = assetFilter.count == assetViewModels.flatMap { $0 }.count ? "전체" : "선택"
            onDidPopUpApply?(false, title)
        }
    }
    
    func handleNumericKeypad(_ value: Decimal, tag: Int) {
        if tag == 0 {
            minAmount = value
        } else {
            maxAmount = value == 0 ? Decimal(Int64.max) : value
        }
        filterTransaction()
    }
    
    func handleSortButton(_ tag: Int) {
        sortCriteria = tag
        sortFilteredTransaction()
    }
    
    func requestReloadTransactions() {
        allTxs = CoreDataManager.shared.fetchTransactions()
        filterTransaction()
    }
    
    private func filterTransaction() {
        filteredTxs = allTxs.filter { tx in
            if let keyword = self.keyword, !keyword.isEmpty {
                guard tx.name.contains(keyword) || tx.memo.contains(keyword) else {
                    return false
                }
            }
            
            if !isEntire {
                guard startDate <= tx.date && tx.date < endDate else {
                    return false
                }
            }
            
            guard categoryFilter.contains(tx.category) else {
                return false
            }
            
            if let asset = tx.asset, !assetFilter.contains(asset) {
                return false
            }
            if let from = tx.fromAccount, let to = tx.toAccount, !assetFilter.contains(from) && !assetFilter.contains(to) {
                return false
            }
            
            let min = NSDecimalNumber(decimal: minAmount).int64Value
            let max = NSDecimalNumber(decimal: maxAmount).int64Value
            guard min <= tx.amount && tx.amount <= max else {
                return false
            }
            
            return true
        }
        
        sortFilteredTransaction()
    }
    
    private func sortFilteredTransaction() {
        switch sortCriteria {
        case 0:
            filteredTxs.sort { $0.date > $1.date }
        case 1:
            filteredTxs.sort { $0.date < $1.date }
        case 2:
            filteredTxs.sort { $0.amount < $1.amount }
        default:
            filteredTxs.sort { $0.amount > $1.amount }
        }
        
        onRequestReloadData?()
    }
}
