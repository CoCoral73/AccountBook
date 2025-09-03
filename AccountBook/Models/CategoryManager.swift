//
//  CategoryManager.swift
//  AccountBook
//
//  Created by 김정원 on 8/2/25.
//

import Foundation

class CategoryManager {
    static let shared = CategoryManager()
    private init() {}
    
    private var categories: [Category] = []
    private(set) var incomeCategories: [Category] = []
    private(set) var expenseCategories: [Category] = []

    func loadCategories() {
        categories = CoreDataManager.shared.fetchCategories()
        incomeCategories = categories.filter { $0.isIncome }
        expenseCategories = categories.filter { !$0.isIncome }
    }

    func addCategory(_ category: Category) {
        categories.append(category)
        CoreDataManager.shared.saveContext()
    }

    func deleteCategory(_ category: Category) {
        if let index = categories.firstIndex(of: category) {
            categories.remove(at: index)
        }
        CoreDataManager.shared.context.delete(category)
        CoreDataManager.shared.saveContext()
    }
}
