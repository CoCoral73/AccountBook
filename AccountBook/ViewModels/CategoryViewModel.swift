//
//  Untitled.swift
//  AccountBook
//
//  Created by 김정원 on 9/17/25.
//

import UIKit

class CategoryViewModel {
    var isIncome: Bool
    var categories: [Category] = []
    
    var onDidSelectCategory: ((Category) -> Void)?
    
    init(isIncome: Bool) {
        self.isIncome = isIncome
        self.categories = isIncome ? CategoryManager.shared.incomeCategories : CategoryManager.shared.expenseCategories
    }
    
    var numberOfItems: Int {
        return (isIncome ? CategoryManager.shared.incomeCategories.count : CategoryManager.shared.expenseCategories.count) + 1
    }
    
    func viewModelOfCell(_ index: Int) -> CategoryCellViewModel {
        let category = (index == numberOfItems - 1) ? nil : categories[index]
        return CategoryCellViewModel(category: category)
    }
    
    func handleDidSelectItemAt(_ index: Int, storyboard: UIStoryboard?, fromVC: UIViewController) {
        if index == numberOfItems - 1 { //추가 뷰
            guard let addVC = storyboard?.instantiateViewController(identifier: "CategoryAddViewController", creator: { coder in
                CategoryAddViewController(coder: coder, viewModel: CategoryAddViewModel(isIncome: self.isIncome))
            }) else {
                fatalError("CategoryAddViewController 생성 에러")
            }
            
            addVC.modalPresentationStyle = .fullScreen
            fromVC.present(addVC, animated: true)
        } else {
            let selected = categories[index]
            onDidSelectCategory?(selected)
        }
    }
}
