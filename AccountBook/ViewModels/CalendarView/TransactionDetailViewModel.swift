//
//  DetailViewModel.swift
//  AccountBook
//
//  Created by 김정원 on 7/8/25.
//

import Foundation

class TransactionDetailViewModel: TransactionUpdatable {
    
    private(set) var state: EditState = .saved
    private(set) var transaction: Transaction
    private var copy: TransactionModel
    
    //DetailTransactionViewControlelr
    var onDidSetTransactionDate: (() -> Void)?
    var onDidSetCategory: (() -> Void)?
    var onDidSetAssetItem: (() -> Void)?
    var onDidSetInstallment: (() -> Void)?
    var onDidSetIsCompleted: (() -> Void)?
    
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
        //이모지로만 돼있음. 추후 변경 필요
        return copy.category.iconName
    }
    var dateString: String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        return dateFormatter.string(from: copy.date)
    }
    var isIncomeString: String {
        return copy.isIncome ? "수입" : "지출"
    }
    var nameString: String {
        return copy.name
    }
    var categoryString: String {
        return copy.category.name
    }
    var priceString: String {
        return (copy.isIncome ? "+" : "-") + self.amountString
    }
    var amountString: String {
        return copy.amount.formattedWithComma
    }
    var assetItemString: String {
        return copy.asset.name
    }
    var assetType: AssetType? {
        guard let type = AssetType(rawValue: Int(copy.asset.type)) else { return nil }
        return type
    }
    var assetTypeString: String {
        guard let assetType = assetType else { return "" }
        return copy.isIncome ? "**입금**" : "**\(assetType.displayName) 거래**"
    }
    var canEdit: Bool {
        return copy.installment == nil
    }
    var isHiddenForInstallment: Bool { assetType != .creditCard }
    var installmentString: String {
        guard let period = transaction.installment?.numberOfMonths, let index = transaction.installmentIndexValue else { return "일시불" }
        return "\(period) 개월 (\(index) / \(period))"
    }
    var isHiddenForIsCompleted: Bool { assetType != .creditCard }
    var titleForIsCompleted: String {
        guard let isCompleted = copy.isCompleted else { return "알수없음" }
        return isCompleted ? "완료" : "미완료"
    }
    var memoString: String? {
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
    
    func handleCategoryButton() -> CategoryViewModel {
        let vm = CategoryViewModel(isIncome: copy.isIncome, autoDismiss: true)
        vm.onDidSelectCategory = { [weak self] category in
            guard let self = self else { return }
            copy.category = category
            state = .modified
            onDidSetCategory?() //UI 변경
        }
        return vm
    }
    
    func handleAssetItemButton() -> AssetSelectionViewModel {
        let vm = AssetSelectionViewModel(isIncome: copy.isIncome)
        vm.onAssetSelected = { [weak self] newAsset in
            guard let self = self else { return }
            copy.asset = newAsset
            copy.isCompleted = newAsset.type != AssetType.creditCard.rawValue
            state = .modified
            onDidSetAssetItem?()
        }
        return vm
    }
    
    func handleInstallmentButton() {
        switch state {
        case .modified:
            let action = canEdit ? "적용" : "제거"
            onRequestSaveAlertBeforeInstallment?(AlertConfig(title: "저장", message: "할부를 \(action)하려면 먼저 변경된 내용을 저장해야 합니다.\n저장하시겠습니까?"))
        case .saved:
            handleInstallmentFlow()
        }
    }
    
    func handleInstallmentFlow() {
        if canEdit {
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
    
    func checkSaveState(name: String?, memo: String?) {
        copy.name = name ?? ""
        copy.memo = memo ?? ""
        
        if copy.name != transaction.name || copy.memo != transaction.memo {
            state = .modified
        }
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
    
    func confirmSave(name: String?, memo: String?) {
        copy.name = name ?? ""
        copy.memo = memo ?? ""
        
        let oldDate = transaction.date, newDate = copy.date
        TransactionManager.shared.updateTransaction(transaction, with: copy)
        if transaction.date != copy.date, Calendar.current.isDate(oldDate, equalTo: copy.date, toGranularity: .month) {
            onDidUpdateOldDateTransaction?(oldDate)
        }
        onDidUpdateTransaction?(newDate)
        state = .saved
    }
    
    func doNotSaveAndExit() {
        copy = TransactionModel(with: transaction)
        state = .saved
    }
}
