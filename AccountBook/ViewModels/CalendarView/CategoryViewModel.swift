//
//  Untitled.swift
//  AccountBook
//
//  Created by 김정원 on 9/17/25.
//

class CategoryViewModel {
    var type: TransactionType
    var autoDismiss: Bool
    var categories: [Category] = []
    
    var onRequestHideNumericKeypad: (() -> Void)?
    var onRequestShowCategoryEditView: ((CategoryEditViewModel) -> Void)?
    var onRequestDismiss: (() -> Void)?
    
    var onDidSelectCategory: ((Category) -> Void)?
    var onDidAddCategory: (() -> ())?
    
    init(type: TransactionType, autoDismiss: Bool) {
        self.type = type
        self.autoDismiss = autoDismiss
        loadCategories()
    }
    
    var numberOfItems: Int {
        return categories.count + 1
    }
    
    func viewModelOfCell(_ index: Int) -> CategoryCellViewModel {
        let category = (index == numberOfItems - 1) ? nil : categories[index]
        return CategoryCellViewModel(category: category)
    }
    
    func handleDidSelectItemAt(_ index: Int) {
        if index == numberOfItems - 1 { //추가 뷰
            let vm = CategoryEditViewModel(type: type, mode: .add)
            vm.onDidEditCategory = { [weak self] in
                guard let self = self else { return }
                loadCategories()
                onDidAddCategory?()
            }
            onRequestShowCategoryEditView?(vm)
        } else {
            let selected = categories[index]
            onDidSelectCategory?(selected)
            if autoDismiss { onRequestDismiss?() }
        }
    }
    
    func loadCategories() {
        switch type {
        case .income:
            categories = CategoryManager.shared.incomeCategories
        case .expense:
            categories = CategoryManager.shared.expenseCategories
        case .transfer:
            categories = CategoryManager.shared.transferCategories
        }
    }
}
