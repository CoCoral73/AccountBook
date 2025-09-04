//
//  TransactionManager.swift
//  AccountBook
//
//  Created by 김정원 on 8/2/25.
//

import Foundation

struct TransactionDelta {
    enum Reason { case mutateSameDay, moveSource, moveDestination, inserted, deleted }
    let date: Date
    let isIncome: Bool
    let amount: Int64
    let reason: Reason
}

class TransactionManager {
    static let shared = TransactionManager()
    private init() {}
    
    func addTransaction(amount: Int64, date: Date, isIncome: Bool, name: String, memo: String, category: Category, asset: AssetItem){
        
        let transaction = Transaction(context: CoreDataManager.shared.context)
        transaction.amount = amount
        transaction.date = date
        transaction.id = UUID()
        transaction.isIncome = isIncome
        transaction.name = name
        transaction.memo = memo
        transaction.category = category
        transaction.asset = asset
        
        CoreDataManager.shared.saveContext()
    }

    func deleteTransaction(_ transaction: Transaction) {
        CoreDataManager.shared.context.delete(transaction)
        CoreDataManager.shared.saveContext()
    }
}
