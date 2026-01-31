//
//  CategoryManager.swift
//  AccountBook
//
//  Created by 김정원 on 8/2/25.
//

import CoreData
import Foundation

class CategoryManager {
    static let shared = CategoryManager()
    private init() {}
    
    private(set) var categories: [Category] = []
    private(set) var incomeCategories: [Category] = []
    private(set) var expenseCategories: [Category] = []
    private(set) var transferCategories: [Category] = []
    var allCategories: [[Category]] {
        return [incomeCategories, expenseCategories, transferCategories]
    }

    func loadCategories() {
        categories = CoreDataManager.shared.fetchCategories()
        incomeCategories = categories.filter { $0.type == .income }
        expenseCategories = categories.filter { $0.type == .expense }
        transferCategories = categories.filter { $0.type == .transfer }
    }
    
    func checkDuplicate(type: TransactionType, name: String) -> Bool {
        switch type {
        case .income:
            return incomeCategories.contains { $0.name == name }
        case .expense:
            return expenseCategories.contains { $0.name == name }
        case .transfer:
            return transferCategories.contains { $0.name == name }
        }
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
        case .transfer:
            category.orderIndex = Int16(transferCategories.count)
            transferCategories.append(category)
        }
        
        categories.append(category)
        CoreDataManager.shared.saveContext()
    }
    
    func updateCategory(with category: Category, icon: String, name: String) {
        category.iconName = icon
        category.name = name
        
        CoreDataManager.shared.saveContext()
        NotificationCenter.default.post(name: .dataDidUpdate, object: nil)
    }

    func removeCategory(_ category: Category) {
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
        case .transfer:
            if let index = transferCategories.firstIndex(of: category) {
                transferCategories.remove(at: index)
                
                for (i, item) in transferCategories.enumerated() {
                    item.orderIndex = Int16(i)
                }
            }
        }
        
        categories.removeAll(where: { $0 == category })
        
        if category.transactions?.count ?? 0 > 0 {
            category.isRemoved = true
        } else {
            CoreDataManager.shared.context.delete(category)
        }
        
        CoreDataManager.shared.saveContext()
        NotificationCenter.default.post(name: .dataDidUpdate, object: nil)
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
        case .transfer:
            let item = transferCategories.remove(at: source)
            transferCategories.insert(item, at: destination)

            for i in 0..<transferCategories.count {
                transferCategories[i].orderIndex = Int16(i)
            }
        }

        CoreDataManager.shared.saveContext()
    }
    
    func deleteCategoryIfNeeded() {
        CoreDataManager.shared.persistentContainer.performBackgroundTask { context in
            let request: NSFetchRequest<Category> = Category.fetchRequest()
            request.predicate = NSPredicate(format: "isRemoved == YES")
            
            do {
                let removed = try context.fetch(request)
                
                for category in removed {
                    if (category.transactions?.count ?? 0) == 0 {
                        context.delete(category)
                    }
                }
                
                if context.hasChanges {
                    try context.save()
                    print("백그라운드, 카테고리 정리 완료")
                }
            } catch {
                print("백그라운드, 카테고리 정리중 오류 발생: \(error)")
            }
        }
    }
}
