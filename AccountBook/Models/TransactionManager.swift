//
//  TransactionManager.swift
//  AccountBook
//
//  Created by 김정원 on 8/2/25.
//

import Foundation

//달력 동기화용
struct TransactionDelta {
    enum Reason { case mutateSameDay, moveSource, moveDestination, inserted, deleted }
    let date: Date
    let isIncome: Bool
    let amount: Int64
    let reason: Reason
}

//코어데이터 객체 생성용
struct TransactionInput {
    let amount: Int64
    let date: Date
    let isIncome: Bool
    let name, memo: String
    let category: Category
    let asset: AssetItem
}

enum DeleteType {
    case general
    case installment
    
    var alertMessage: String {
        switch self {
        case .general:
            return "거래내역을 삭제하시겠습니까?"
        case .installment:
            return "할부내역 전체가 삭제됩니다. 삭제하시겠습니까?"
        }
    }
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
        // 할부 거래 중 일부를 삭제하려고 하면 → 전체 할부 삭제
        for tx in transaction.installment?.transactions.array as? [Transaction] ?? [transaction] {
            CoreDataManager.shared.context.delete(tx)
        }
        CoreDataManager.shared.saveContext()
    }
}
