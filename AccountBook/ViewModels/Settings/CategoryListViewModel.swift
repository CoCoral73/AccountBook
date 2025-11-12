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
        //코어데이터 모델 순서 프로퍼티 수정 필요
        let item = categories.remove(at: source)
        categories.insert(item, at: destination)
    }
    
    func loadCategories() {
        categories = isIncome ? CategoryManager.shared.incomeCategories : CategoryManager.shared.expenseCategories
    }
}
