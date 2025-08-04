//
//  AddViewModel.swift
//  AccountBook
//
//  Created by 김정원 on 7/9/25.
//

import UIKit

class AddViewModel {
    
    private var currentDate: Date {
        didSet {
            onDidSetCurrentDate?()
        }
    }
    
    var amountInput: Int64 = 0
    var assetInput: AssetItem?
    var memoInput: String = ""
    
    private var isIncome: Bool
    
    var onDidSetCurrentDate: (() -> Void)?
    var onDidAddTransaction: (() -> Void)?
    
    init(currentDate: Date, isIncome: Bool) {
        self.currentDate = currentDate
        self.isIncome = isIncome
    }
    
    var currentDateString: String {
        let df = DateFormatter()
        df.dateFormat = "yyyy년 M월 d일"
        return df.string(from: currentDate)
    }
    
    var numberOfItemsInSection: Int {
        return isIncome ? CategoryManager.shared.incomeCategories.count : CategoryManager.shared.expenseCategories.count
    }
    
    private var categories: [Category] {
        return isIncome ? CategoryManager.shared.incomeCategories : CategoryManager.shared.expenseCategories
    }
    
    func getCategory(with index: Int) -> Category {
        return categories[index]
    }
    
    func addTransaction(with index: Int) {
        guard let asset = assetInput else {
            //자산 선택 안됐을때 동작 설정하기
            return
        }
        
        TransactionManager.shared.addTransaction(amount: amountInput, date: currentDate, isIncome: isIncome, memo: memoInput, category: getCategory(with: index), asset: asset)
        onDidAddTransaction?()
    }
    
    func handleDateButton(storyboard: UIStoryboard?, fromVC: UIViewController) {
        let vm = DatePickerViewModel(initialDate: currentDate)
        vm.onDatePickerChanged = { [weak self] date in
            guard let self = self else { return }
            self.currentDate = date
        }
        
        guard let dateVC = storyboard?.instantiateViewController(identifier: "DatePickerViewController", creator: { coder in
            DatePickerViewController(coder: coder, viewModel: vm) })
        else {
            fatalError("DatePickerViewController 생성 에러")
        }
        
        if let sheet = dateVC.sheetPresentationController {
            sheet.detents = [.medium()]
        }
        fromVC.present(dateVC, animated: true, completion: nil)
    }
}
