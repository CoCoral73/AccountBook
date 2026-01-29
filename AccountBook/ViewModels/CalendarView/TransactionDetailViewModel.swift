//
//  DetailViewModel.swift
//  AccountBook
//
//  Created by 김정원 on 7/8/25.
//

import Foundation

class TransactionDetailViewModel: TransactionUpdatable {
    
    private(set) var state: EditState = .saved {
        didSet {
            onDidChangeState?(state == .saved)
        }
    }
    private(set) var transaction: Transaction
    private var copy: TransactionModel
    
    //DetailTransactionViewControlelr
    var onDidChangeState: ((Bool) -> Void)?
    var onDidSetTransactionDate: (() -> Void)?
    var onDidSetCategory: (() -> Void)?
    var onDidSetAssetItem: (() -> Void)?
    var onDidSetAccount: ((Int) -> Void)?
    var onDidSetInstallment: (() -> Void)?
    var onDidSetIsCompleted: (() -> Void)?
    
    var onRequestInvalidDataFeedback: ((String) -> Void)?
    var onRequestDeleteInstallmentAlert: ((AlertConfig) -> Void)?
    var onRequestDeleteAlert: ((AlertConfig) -> Void)?
    var onRequestBlockPopAlert: (() -> Void)?
    var onRequestSaveAlert: ((AlertConfig) -> Void)?
    var onRequestSaveAlertBeforeInstallment: ((AlertConfig) -> Void)?
    var onRequestSaveAlertBeforeDeleteInstallment: ((AlertConfig) -> Void)?
    var onRequestSaveAlertBeforeIsCompleted: ((AlertConfig) -> Void)?
    var onRequestIsCompletedAlert: ((AlertConfig) -> Void)?
    var onRequestPop: (() -> Void)?
    var onShowInstallmentView: ((InstallmentViewModel) -> Void)?
    
    //CalendarViewModel
    var onDidUpdateOldDateTransaction: ((Date) -> Void)?
    var onDidUpdateTransaction: ((Date) -> Void)?   //TransactionUpdatable
    
    init(transaction: Transaction) {
        self.transaction = transaction
        self.copy = TransactionModel(with: transaction)
    }
    
    var imageName: String {
        return copy.category.iconName
    }
    var dateDisplay: String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        return dateFormatter.string(from: copy.date)
    }
    var transactionTypeName: String {
        return copy.type.name
    }
    var transactionName: String {
        return copy.name
    }
    var categoryName: String {
        return copy.category.name
    }
    var signedAmountDisplay: String {
        let prefix: String
        switch copy.type {
        case .income:
            prefix = "+"
        case .expense:
            prefix = "-"
        case .transfer:
            prefix = ""
        }
        return prefix + self.amountDisplay
    }
    var amountDisplay: String {
        return copy.amount.formattedWithComma + "원"
    }
    var isAssetViewHidden: Bool {
        return copy.type == .transfer
    }
    var assetName: String {
        if copy.type != .transfer {
            return copy.asset?.name ?? "(알 수 없음)"
        } else {
            return "\(copy.fromAccount?.name ?? "(알 수 없음)") > \(copy.toAccount?.name ?? "(알 수 없음)")"
        }
    }
    var assetTypeDisplay: String {
        if copy.type == .transfer { return "**계좌 이체**"}
        else if copy.type == .income { return "**입금**" }
        else {
            let name = copy.asset?.type.displayName ?? ""
            return "**\(name) 결제**"
        }
    }
    var isAccountViewHidden: Bool {
        return copy.type != .transfer
    }
    var fromAccountName: String {
        guard copy.type == .transfer else { return "" }
        return copy.fromAccount?.name ?? "(알 수 없음)"
    }
    var toAccountName: String {
        guard copy.type == .transfer else { return "" }
        return copy.toAccount?.name ?? "(알 수 없음)"
    }
    var shouldEdit: Bool {
        return copy.installment == nil
    }
    var isInstallmentViewHidden: Bool {
        if copy.type == .income || copy.type == .transfer { return true }
        if let asset = copy.asset, asset.type == .creditCard {
            return false
        }
        return true
    }
    var installmentDisplay: String {
        guard let period = transaction.installment?.numberOfMonths, let index = transaction.installmentIndexValue else { return "일시불" }
        return "\(period) 개월 (\(index) / \(period))"
    }
    var isIsCompletedViewHidden: Bool {
        return self.isInstallmentViewHidden
    }
    var isCompletedDisplay: String {
        guard let isCompleted = copy.isCompleted else { return "(알 수 없음)" }
        return isCompleted ? "완료" : "미완료"
    }
    var memo: String? {
        return copy.memo
    }
    
    func handleDateButton() -> DatePickerViewModel {
        let vm = DatePickerViewModel(initialDate: transaction.date)
        vm.onDatePickerChanged = { [weak self] newDate in
            guard let self = self else { return }
            copy.date = newDate
            state = .modified
            onDidSetTransactionDate?()  //UI 변경
        }
        return vm
    }
    
    func handleNameChanged(_ name: String?) {
        copy.name = name ?? ""
        state = .modified
    }
    
    func handleNumericKeypad(_ value: Decimal) {
        let amount = NSDecimalNumber(decimal: value).int64Value
        copy.amount = amount
        
        if transaction.amount != copy.amount {
            state = .modified
        }
    }
    
    func handleCategoryButton() -> CategoryViewModel {
        let vm = CategoryViewModel(type: copy.type, autoDismiss: true)
        vm.onDidSelectCategory = { [weak self] category in
            guard let self = self else { return }
            copy.category = category
            state = .modified
            onDidSetCategory?() //UI 변경
        }
        return vm
    }
    
    func handleAssetItemButton() -> AssetSelectionViewModel {
        let vm = AssetSelectionViewModel(type: copy.type)
        vm.onAssetSelected = { [weak self] newAsset in
            guard let self = self else { return }
            copy.asset = newAsset
            copy.isCompleted = newAsset.type != AssetType.creditCard
            state = .modified
            onDidSetAssetItem?()
        }
        return vm
    }
    
    func handleAccountButton(tag: Int) -> AssetSelectionViewModel {
        let vm = AssetSelectionViewModel(type: copy.type)
        vm.onAssetSelected = { [weak self] newAsset in
            guard let self = self else { return }
            guard let account = newAsset as? BankAccountItem else { return }
            
            if tag == 0 { copy.fromAccount = account }
            else { copy.toAccount = account }
            state = .modified
            onDidSetAccount?(tag)
        }
        return vm
    }
    
    func handleInstallmentButton() {
        switch state {
        case .modified:
            let action = shouldEdit ? "적용" : "제거"
            onRequestSaveAlertBeforeInstallment?(AlertConfig(title: "저장", message: "할부를 \(action)하려면 먼저 변경된 내용을 저장해야 합니다.\n저장하시겠습니까?"))
        case .saved:
            handleInstallmentFlow()
        }
    }
    
    func handleInstallmentFlow() {
        if shouldEdit {
            requestInstallmentViewPresentation()
        } else {
            requestDeleteInstallmentAlertPresentation()
        }
    }
    
    func handleIsCompletedButton() {
        guard let isCompleted = copy.isCompleted else { return }
        let action = isCompleted ? "취소" : "완료"
        switch state {
        case .modified:
            onRequestSaveAlertBeforeIsCompleted?(AlertConfig(title: "저장", message: "결제 \(action) 처리를 하려면 먼저 변경된 내용을 저장해야 합니다.\n저장하시겠습니까?"))
        case .saved:
            requestIsCompletedAlert()
        }

    }
    
    func requestIsCompletedAlert() {
        guard let isCompleted = copy.isCompleted else { return }
        switch isCompleted {
        case true:
            onRequestIsCompletedAlert?(AlertConfig(title: "결제 취소", message: "이미 결제 완료된 거래입니다.\n결제를 취소하시겠습니까?"))
        case false:
            onRequestIsCompletedAlert?(AlertConfig(title: "결제 완료", message: "결제 완료 처리하시겠습니까?\n거래 금액은 연결된 계좌에서 차감됩니다."))
        }
    }
    
    func confirmIsCompleted() {
        guard let isCompleted = copy.isCompleted else { return }
        switch isCompleted {
        case true:
            TransactionManager.shared.cancelTransaction(transaction, shouldSave: true)
        case false:
            TransactionManager.shared.completeTransaction(transaction, shouldSave: true)
        }
        copy.isCompleted = transaction.isCompleted
        onDidSetIsCompleted?()
    }
    
    func handleMemoChanged(_ memo: String!) {
        copy.memo = memo
        state = .modified
    }
    
    func requestInstallmentViewPresentation() {
        let vm = InstallmentViewModel()
        vm.onDidEnterInstallment = { [weak self] period in
            guard let self = self, period > 1 else { return }

            InstallmentManager.shared.addInstallment(transaction, period: period)
            copy.installment = period
            copy.installmentIndex = transaction.installmentIndexValue
            copy.amount = transaction.amount
            
            onDidSetInstallment?()
            onDidUpdateTransaction?(transaction.date)
        }
        onShowInstallmentView?(vm)
    }
    
    func requestDeleteInstallmentAlertPresentation() {
        onRequestDeleteInstallmentAlert?(AlertConfig(title: "할부 제거", message: "적용된 할부를 제거하시겠습니까?\n이 동작은 즉시 저장됩니다."))
    }
    
    func confirmDeleteInstallment() {
        let isFirst = transaction.installmentIndexValue == 1
        let date = transaction.date
        InstallmentManager.shared.deleteInstallment(transaction)
        onDidUpdateTransaction?(date)
        
        if isFirst {
            copy.installment = transaction.installment?.numberOfMonths
            copy.installmentIndex = transaction.installmentIndexValue
            copy.amount = transaction.amount
            onDidSetInstallment?()
        } else {
            onRequestPop?()
        }
    }
    
    func handleRemoveButton() {
        let deleteType = transaction.installment != nil ? DeleteType.installment : DeleteType.general
        onRequestDeleteAlert?(AlertConfig(title: "삭제", message: deleteType.alertMessage))
    }
    
    func confirmDelete() {
        let date = transaction.date
        TransactionManager.shared.deleteTransaction(transaction)
        onDidUpdateTransaction?(date)
        onRequestPop?()
    }
    
    func handleBackButton() {
        switch state {
        case .modified:
            onRequestBlockPopAlert?()
        case .saved:
            onRequestPop?()
        }
    }
    
    func handleSaveButton() {
        onRequestSaveAlert?(AlertConfig(title: "저장", message: "변경사항을 저장하시겠습니까?"))
    }
    
    @discardableResult
    func confirmSave(name: String?, memo: String?) -> Bool {
        copy.name = name ?? ""
        copy.memo = memo ?? ""
        
        let oldDate = transaction.date, newDate = copy.date
        
        let result = TransactionManager.shared.updateTransaction(transaction, with: copy)
        if !result {
            onRequestInvalidDataFeedback?("동일한 계좌로는 이체할 수 없습니다.")
            return false
        }
        
        if transaction.date != copy.date, Calendar.current.isDate(oldDate, equalTo: copy.date, toGranularity: .month) {
            onDidUpdateOldDateTransaction?(oldDate)
        }
        onDidUpdateTransaction?(newDate)
        state = .saved
        
        return true
    }
    
    func doNotSaveAndExit() {
        copy = TransactionModel(with: transaction)
        state = .saved
    }
}
