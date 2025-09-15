//
//  AddViewModel.swift
//  AccountBook
//
//  Created by 김정원 on 7/9/25.
//

import UIKit

class TransactionAddViewModel {
    
    private var transactionDate: Date {
        didSet {
            onDidSetTransactionDate?()
        }
    }
    
    var inputVC: TransactionAddTableViewController?
    private var assetItemInput: AssetItem?
    
    private(set) var isIncome: Bool
    
    //Add View에서 currentDate가 바뀌면  바 버튼 아이템의 날짜 타이틀이 바뀌도록
    var onDidSetTransactionDate: (() -> Void)?
    
    //Add View에서 내역 추가 동작을 했을 때, Calendar View에서 해야할 일
    var onDidAddTransaction: ((Date) -> Void)?
    
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
    
    func addTransaction(with category: Category) {
        guard let asset = assetItemInput else {
            //자산 선택 안됐을때 동작 설정하기
            return
        }
        
        let amountInput = Int64((inputVC?.amountTextField.text ?? "").replacingOccurrences(of: ",", with: "")) ?? 0
        let nameInput = inputVC?.nameTextField.text ?? ""
        
        let input = TransactionInput(amount: amountInput, date: transactionDate, isIncome: isIncome, name: nameInput, memo: "", category: category, asset: asset)
        TransactionManager.shared.addTransaction(with: input, shouldSave: true)
        onDidAddTransaction?(transactionDate)
    }
    
    func handleDateButton(storyboard: UIStoryboard?, fromVC: UIViewController) {
        let vm = DatePickerViewModel(initialDate: transactionDate)
        vm.onDatePickerChanged = { [weak self] date in
            guard let self = self else { return }
            self.transactionDate = date
        }
        
        guard let dateVC = storyboard?.instantiateViewController(identifier: "DatePickerViewController", creator: { coder in
            DatePickerViewController(coder: coder, viewModel: vm) })
        else {
            fatalError("DatePickerViewController 생성 에러")
        }
        
        if let sheet = dateVC.sheetPresentationController {
            sheet.detents = [.medium()]
        }
        fromVC.present(dateVC, animated: true)
    }
    
    func handleCategoryView(storyboard: UIStoryboard?, fromVC: TransactionAddViewController) {
        let isIncome = isIncome
        guard let childVC = storyboard?.instantiateViewController(identifier: "CategoryViewController", creator: { coder in
            CategoryViewController(coder: coder, isIncome: isIncome)
        }) else {
            fatalError("CategoryViewController 생성 에러")
        }
        
        childVC.onDidSelectCategory = { [weak self] category in
            guard let self = self else { return }
            addTransaction(with: category)
            fromVC.dismiss(animated: true)
        }
        
        //embed 세그웨이 역할
        fromVC.addChild(childVC)
        childVC.view.frame = fromVC.containerViewForCategory.bounds
        fromVC.containerViewForCategory.addSubview(childVC.view)
        childVC.didMove(toParent: fromVC)
    }
}
