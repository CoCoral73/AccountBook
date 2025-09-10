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

struct TransactionInput {
    let amount: Int64
    let date: Date
    let isIncome: Bool
    let name, memo: String
    let category: Category
    let asset: AssetItem
}

class TransactionManager {
    static let shared = TransactionManager()
    private init() {}
    
    @discardableResult
    func addTransaction(with input: TransactionInput, shouldSave: Bool) -> Transaction {
        
        let transaction = Transaction(context: CoreDataManager.shared.context)
        transaction.amount = input.amount
        transaction.date = input.date
        transaction.id = UUID()
        transaction.isIncome = input.isIncome
        transaction.name = input.name
        transaction.memo = input.memo
        transaction.category = input.category
        transaction.asset = input.asset
        
        if shouldSave {
            CoreDataManager.shared.saveContext()
        }
        
        return transaction
    }
    
    //할부 거래 생성용
    func duplicateTransaction(_ tx: Transaction, count: Int16) -> [Transaction] {
        var txs = [tx]
        for i in 1..<Int(count) {
            let input = TransactionInput(amount: tx.amount, date: Calendar.current.date(byAdding: .month, value: i, to: tx.date)!, isIncome: tx.isIncome, name: tx.name, memo: tx.memo, category: tx.category, asset: tx.asset)
            txs.append(addTransaction(with: input, shouldSave: false))
        }
        return txs
    }

    func deleteTransaction(_ transaction: Transaction) {
        CoreDataManager.shared.context.delete(transaction)
        CoreDataManager.shared.saveContext()
    }
}
