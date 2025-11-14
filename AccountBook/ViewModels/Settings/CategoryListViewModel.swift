//
//  CategoryListViewModel.swift
//  AccountBook
//
//  Created by 김정원 on 11/12/25.
//

class CategoryListViewModel {
    private(set) var isIncome: Bool
    private var categories: [Category] = []
    
    init(isIncome: Bool) {
        self.isIncome = isIncome
        loadCategories()
    }
    
    var numberOfRowsInSection: Int { categories.count }
    func cellForRowAt(row: Int) -> Category { categories[row] }
    
    func moveRowAt(source: Int, destination: Int) {
        CategoryManager.shared.reorderCategory(isIncome: isIncome, source: source, destination: destination)
        loadCategories()
    }
    
    func loadCategories() {
        categories = isIncome ? CategoryManager.shared.incomeCategories : CategoryManager.shared.expenseCategories
    }
}
