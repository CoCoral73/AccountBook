//
//  AddViewModel.swift
//  AccountBook
//
//  Created by 김정원 on 7/9/25.
//

import Foundation

class TransactionAddViewModel: TransactionUpdatable {
    
    private var transactionDate: Date {
        didSet {
            onDidSetTransactionDate?()
        }
    }
    
    private var amountInput: Decimal = 0
    private var assetInput: AssetItem?
    private var fromAccountInput: BankAccountItem?
    private var toAccountInput: BankAccountItem?
    
    private(set) var type: TransactionType
    
    //Add View에서 currentDate가 바뀌면  바 버튼 아이템의 날짜 타이틀이 바뀌도록
    var onDidSetTransactionDate: (() -> Void)?
    
    //Add View에서 내역 추가 동작을 했을 때, Calendar View에서 해야할 일
    var onDidUpdateTransaction: ((Date) -> Void)?
    
    //자산 선택 완료 -> TransactionAddTableVC
    var onDidSelectAsset: ((String) -> Void)?   //수입, 지출
    var onDidSelectAccount: ((Bool, String) -> Void)?   //이체
    
    var onRequestDatePickerViewPresentation: ((DatePickerViewModel) -> Void)?
    var onRequestAssetSelectionViewPresentation: ((AssetSelectionViewModel) -> Void)?
    var onRequestNameText: (() -> String)?
    var onRequestFeedbackForInvalidData: ((String) -> Void)?
    var onRequestDismiss: (() -> Void)?
    
    init(date: Date, type: TransactionType) {
        self.transactionDate = date
        self.type = type
    }
    
    var transactionDateDisplay: String {
        let df = DateFormatter()
        df.dateFormat = "yyyy년 M월 d일"
        return df.string(from: transactionDate)
    }
    var isAccountViewHidden: Bool {
        return type != .transfer
    }
    
    func setAssetInput(with item: AssetItem) {
        self.assetInput = item
    }
    
    func setAccountInput(isFrom: Bool, with item: BankAccountItem) {
        if isFrom {
            fromAccountInput = item
        } else {
            toAccountInput = item
        }
    }
    
    func addTransaction(amount: Int64, asset: AssetItem, name: String, category: Category) {
        let input = TransactionModel(amount: amount, date: transactionDate, type: type, name: name, memo: "", category: category, asset: asset)
        TransactionManager.shared.addTransaction(with: input, shouldSave: true)
        onDidUpdateTransaction?(transactionDate)
    }
    
    func addTransfer(amount: Int64, fromAccount: BankAccountItem, toAccount: BankAccountItem, name: String, category: Category) {
        let input = TransactionModel(amount: amount, date: transactionDate, type: type, name: name, memo: "", category: category, fromAccount: fromAccount, toAccount: toAccount)
        TransactionManager.shared.addTransfer(with: input)
        onDidUpdateTransaction?(transactionDate)
    }
    
    func handleDateButton() {
        let vm = DatePickerViewModel(initialDate: transactionDate)
        vm.onDatePickerChanged = { [weak self] date in
            guard let self = self else { return }
            self.transactionDate = date
        }
        onRequestDatePickerViewPresentation?(vm)
    }
    
    func handleAssetView() {
        let vm = AssetSelectionViewModel(type: type)
        vm.onAssetSelected = { [weak self] asset in
            guard let self = self else { return }
            setAssetInput(with: asset)
            onDidSelectAsset?(asset.name)
        }
        onRequestAssetSelectionViewPresentation?(vm)
    }
    
    func handleAccountView(_ isFrom: Bool) {
        let vm = AssetSelectionViewModel(type: type)
        vm.onAssetSelected = { [weak self] account in
            guard let self = self else { return }
            setAccountInput(isFrom: isFrom, with: account as! BankAccountItem)
            onDidSelectAccount?(isFrom, account.name)
        }
        onRequestAssetSelectionViewPresentation?(vm)
    }
    
    func handleCategoryView() -> CategoryViewModel {
        let vm = CategoryViewModel(type: type, autoDismiss: false)
        vm.onDidSelectCategory = { [weak self] category in
            guard let self = self else { return }
            
            let amount = NSDecimalNumber(decimal: amountInput).int64Value
            guard amount > 0 else {
                onRequestFeedbackForInvalidData?("0원 이하의 금액은 입력할 수 없습니다.")
                return
            }
            
            guard let asset = assetInput else {
                onRequestFeedbackForInvalidData?("자산을 선택해주세요.")
                return
            }
            
            let name = (onRequestNameText?() ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
            
            addTransaction(amount: amount, asset: asset, name: name, category: category)
            onRequestDismiss?()
        }
        return vm
    }
    
    func handleNumericKeypad(_ value: Decimal) {
        amountInput = value
    }
}
