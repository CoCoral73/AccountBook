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
    
    private var isIncome: Bool
    
    var onDidSetCurrentDate: (() -> Void)?
    
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
    
    var categories: [Category] {
        return isIncome ? CategoryManager.shared.incomeCategories : CategoryManager.shared.expenseCategories
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
