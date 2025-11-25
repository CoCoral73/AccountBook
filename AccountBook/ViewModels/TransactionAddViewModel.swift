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
    
    var inputVC: TransactionAddTableViewController? //텍스트필드 접근 시 사용
    private var assetItemInput: AssetItem?
    
    private(set) var isIncome: Bool
    
    //Add View에서 currentDate가 바뀌면  바 버튼 아이템의 날짜 타이틀이 바뀌도록
    var onDidSetTransactionDate: (() -> Void)?
    
    //Add View에서 내역 추가 동작을 했을 때, Calendar View에서 해야할 일
    var onDidUpdateTransaction: ((Date) -> Void)?
    
    //자산 선택 완료 -> TransactionAddTableVC
    var onDidSelectAsset: ((String) -> Void)?
    
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
    
    func addTransaction(amount: Int64, asset: AssetItem, category: Category) {
        let name = inputVC?.nameTextField.text ?? ""
        
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
    
    func handleCategoryView(storyboard: UIStoryboard?, fromVC: TransactionAddViewController) {
        guard let childVC = storyboard?.instantiateViewController(identifier: "CategoryViewController", creator: { coder in
            CategoryViewController(coder: coder, viewModel: CategoryViewModel(isIncome: self.isIncome))
        }) else {
            fatalError("CategoryViewController 생성 에러")
        }
        
        childVC.viewModel.onDidSelectCategory = { [weak self] category in
            guard let self = self else { return }
            
            guard (inputVC?.amountTextField.text ?? "") != "", let asset = assetItemInput else {
                fromVC.view.endEditing(true)
                HapticFeedback.notify(.error)
                ToastManager.shared.show(message: "금액과 자산을 입력해주세요", in: childVC.view)
                return
            }
            
            guard let amount = Int64((inputVC?.amountTextField.text ?? "").replacingOccurrences(of: ",", with: "")), amount > 0 else {
                fromVC.view.endEditing(true)
                HapticFeedback.notify(.error)
                ToastManager.shared.show(message: "0원 이하의 금액은 입력 불가합니다.", in: fromVC.view)
                return
            }
            
            addTransaction(amount: amount, asset: asset, category: category)
            fromVC.dismiss(animated: true)
        }
        
        //embed 세그웨이 역할
        fromVC.addChild(childVC)
        childVC.view.frame = fromVC.containerViewForCategory.bounds
        fromVC.containerViewForCategory.addSubview(childVC.view)
        childVC.didMove(toParent: fromVC)
    }
}
