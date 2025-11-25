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
    
    private var assetItemInput: AssetItem?
    
    private(set) var isIncome: Bool
    
    //Add View에서 currentDate가 바뀌면  바 버튼 아이템의 날짜 타이틀이 바뀌도록
    var onDidSetTransactionDate: (() -> Void)?
    
    //Add View에서 내역 추가 동작을 했을 때, Calendar View에서 해야할 일
    var onDidUpdateTransaction: ((Date) -> Void)?
    
    //자산 선택 완료 -> TransactionAddTableVC
    var onDidSelectAsset: ((String) -> Void)?
    
    var onRequestTextData: (() -> (amount: String?, name: String?))?
    var onRequestFeedbackForNoData: ((String) -> Void)?
    var onRequestFeedbackForInvalidData: ((String) -> Void)?
    var onRequestDismiss: (() -> Void)?
    
    init(date: Date, isIncome: Bool) {
        self.transactionDate = date
        self.isIncome = isIncome
    }
    
    var transactionDateString: String {
        let df = DateFormatter()
        df.dateFormat = "yyyy년 M월 d일"
        return df.string(from: transactionDate)
    }
    
    func setAssetItemInput(with item: AssetItem) {
        self.assetItemInput = item
    }
    
    func addTransaction(amount: Int64, asset: AssetItem, name: String, category: Category) {
        let input = TransactionModel(amount: amount, date: transactionDate, isIncome: isIncome, name: name, memo: "", category: category, asset: asset)
        TransactionManager.shared.addTransaction(with: input, shouldSave: true)
        onDidUpdateTransaction?(transactionDate)
    }
    
    func handleDateButton() -> DatePickerViewModel {
        let vm = DatePickerViewModel(initialDate: transactionDate)
        vm.onDatePickerChanged = { [weak self] date in
            guard let self = self else { return }
            self.transactionDate = date
        }
        return vm
    }
    
    func handlePaymentSelectionButton() -> AssetSelectionViewModel {
        let vm = AssetSelectionViewModel(isIncome: isIncome)
        vm.onAssetSelected = { [weak self] asset in
            guard let self = self else { return }
            setAssetItemInput(with: asset)
            onDidSelectAsset?(asset.name)
        }
        return vm
    }
    
    func handleCategoryView() -> CategoryViewModel {
        let vm = CategoryViewModel(isIncome: isIncome)
        vm.onDidSelectCategory = { [weak self] category in
            guard let self = self else { return }
            let data = onRequestTextData?()
            
            guard (data?.amount ?? "") != "", let asset = assetItemInput else {
                onRequestFeedbackForNoData?("금액과 자산을 입력해주세요.")
                return
            }
            
            guard let amount = Int64((data?.amount ?? "").replacingOccurrences(of: ",", with: "")), amount > 0 else {
                onRequestFeedbackForInvalidData?("0원 이하의 금액은 입력 불가합니다.")
                return
            }
            
            let name = (data?.name ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
            
            addTransaction(amount: amount, asset: asset, name: name, category: category)
            onRequestDismiss?()
        }
        return vm
    }
}
