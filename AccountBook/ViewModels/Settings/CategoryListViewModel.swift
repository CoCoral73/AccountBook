//
//  CategoryListViewModel.swift
//  AccountBook
//
//  Created by 김정원 on 11/12/25.
//

class CategoryListViewModel {
    private(set) var type: TransactionType
    private var categories: [Category] = []
    
    init(type: TransactionType) {
        self.type = type
        loadCategories()
    }
    
    var title: String {
        switch type {
        case .income:
            return "수입 카테고리"
        case .expense:
            return "지출 카테고리"
        case .transfer:
            return "이체 카테고리"
        }
    }
    var numberOfRowsInSection: Int { categories.count }
    func cellForRowAt(row: Int) -> Category { categories[row] }
    
    func moveRowAt(source: Int, destination: Int) {
        CategoryManager.shared.reorderCategory(type: type, source: source, destination: destination)
        loadCategories()
    }
    
    func didSelectRowAt(row: Int) -> CategoryEditViewModel {
        let category = categories[row]
        return CategoryEditViewModel(type: type, mode: .edit(category))
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
