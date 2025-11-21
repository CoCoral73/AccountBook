//
//  Untitled.swift
//  AccountBook
//
//  Created by 김정원 on 9/17/25.
//

class CategoryViewModel {
    var isIncome: Bool
    var categories: [Category] = []
    
    var onDidSelectCategory: ((Category) -> Void)?
    var onDidAddCategory: (() -> ())?
    
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
    
    func handleDidSelectItemAt(_ index: Int) -> CategoryEditViewModel? {
        if index == numberOfItems - 1 { //추가 뷰
            let vm = CategoryEditViewModel(isIncome: isIncome, mode: .add)
            vm.onDidEditCategory = { [weak self] in
                guard let self = self else { return }
                loadCategories()
                onDidAddCategory?()
            }
            
            return vm
        } else {
            let selected = categories[index]
            onDidSelectCategory?(selected)
            return nil
        }
    }
    
    func loadCategories() {
        categories = isIncome ? CategoryManager.shared.incomeCategories : CategoryManager.shared.expenseCategories
    }
}
