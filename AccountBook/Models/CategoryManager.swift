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
        incomeCategories = categories.filter { $0.type == .income }
        expenseCategories = categories.filter { $0.type == .expense }
    }

    func addCategory(icon: String, name: String, type: TransactionType) {
        let category = Category(context: CoreDataManager.shared.context)
        category.id = UUID()
        category.iconName = icon
        category.name = name
        category.typeValue = type.rawValue
    
        switch type {
        case .income:
            category.orderIndex = Int16(incomeCategories.count)
            incomeCategories.append(category)
        case .expense:
            category.orderIndex = Int16(expenseCategories.count)
            expenseCategories.append(category)
        }
        
        CoreDataManager.shared.saveContext()
    }
    
    func updateCategory(with category: Category, icon: String, name: String) {
        category.iconName = icon
        category.name = name
        
        CoreDataManager.shared.saveContext()
    }

    func deleteCategory(_ category: Category) {
        switch category.type {
        case .income:
            if let index = incomeCategories.firstIndex(of: category) {
                incomeCategories.remove(at: index)
                
                for (i, item) in incomeCategories.enumerated() {
                    item.orderIndex = Int16(i)
                }
            }
        case .expense:
            if let index = expenseCategories.firstIndex(of: category) {
                expenseCategories.remove(at: index)
                
                for (i, item) in expenseCategories.enumerated() {
                    item.orderIndex = Int16(i)
                }
            }
            }
        }
        
        CoreDataManager.shared.context.delete(category)
        CoreDataManager.shared.saveContext()
    }
    
    func reorderCategory(type: TransactionType, source: Int, destination: Int) {
        switch type {
        case .income:
            let item = incomeCategories.remove(at: source)
            incomeCategories.insert(item, at: destination)

            for i in 0..<incomeCategories.count {
                incomeCategories[i].orderIndex = Int16(i)
            }
        case .expense:
            let item = expenseCategories.remove(at: source)
            expenseCategories.insert(item, at: destination)

            for i in 0..<expenseCategories.count {
                expenseCategories[i].orderIndex = Int16(i)
            }
        }

        CoreDataManager.shared.saveContext()
    }
}
