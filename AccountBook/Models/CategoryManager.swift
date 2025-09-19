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

    func addCategory(icon: String, name: String, isIncome: Bool) {
        let category = Category(context: CoreDataManager.shared.context)
        category.id = UUID()
        category.iconName = icon
        category.name = name
        category.isIncome = isIncome
    
        if isIncome {
            incomeCategories.append(category)
        } else {
            expenseCategories.append(category)
        }
        CoreDataManager.shared.saveContext()
    }

    func deleteCategory(_ category: Category) {
        if category.isIncome, let index = incomeCategories.firstIndex(of: category) {
            incomeCategories.remove(at: index)
        } else if !category.isIncome, let index = expenseCategories.firstIndex(of: category) {
            expenseCategories.remove(at: index)
        }
        
        CoreDataManager.shared.context.delete(category)
        CoreDataManager.shared.saveContext()
    }
}
