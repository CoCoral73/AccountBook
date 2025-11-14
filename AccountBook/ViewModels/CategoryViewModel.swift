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
        loadCategories()
    }
    
    var numberOfItems: Int {
        return categories.count + 1
    }
    
    func viewModelOfCell(_ index: Int) -> CategoryCellViewModel {
        let category = (index == numberOfItems - 1) ? nil : categories[index]
        return CategoryCellViewModel(category: category)
    }
    
    func handleDidSelectItemAt(_ index: Int, storyboard: UIStoryboard?, fromVC: UIViewController) {
        if index == numberOfItems - 1 { //추가 뷰
            guard let addVC = storyboard?.instantiateViewController(identifier: "CategoryEditViewController", creator: { coder in
                CategoryEditViewController(coder: coder, viewModel: CategoryEditViewModel(isIncome: self.isIncome))
            }) else {
                fatalError("CategoryEditViewController 생성 에러")
            }
            addVC.viewModel.onDidAddCategory = {
                self.loadCategories()
                (fromVC as! CategoryViewController).collectionView.reloadData()
            }
            
            let navVC = UINavigationController(rootViewController: addVC)
            navVC.modalPresentationStyle = .fullScreen
            fromVC.present(navVC, animated: true)
        } else {
            let selected = categories[index]
            onDidSelectCategory?(selected)
        }
    }
    
    func loadCategories() {
        categories = isIncome ? CategoryManager.shared.incomeCategories : CategoryManager.shared.expenseCategories
    }
}
