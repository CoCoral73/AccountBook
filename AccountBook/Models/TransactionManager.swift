//
//  TransactionManager.swift
//  AccountBook
//
//  Created by 김정원 on 8/2/25.
//

import Foundation

struct TransactionModel {
    var amount: Int64
    var date: Date
    let isIncome: Bool
    var name, memo: String
    var category: Category
    var asset: AssetItem
    var installment: Int16?
    var installmentIndex: Int16?
    var isCompleted: Bool?
}

extension TransactionModel {
    init(with tx: Transaction) {
        amount = tx.amount
        date = tx.date
        isIncome = tx.isIncome
        name = tx.name
        memo = tx.memo
        category = tx.category
        asset = tx.asset
        installment = tx.installment?.numberOfMonths
        installmentIndex = tx.installmentIndexValue
        isCompleted = tx.isCompleted
    }
}

enum DeleteType {
    case general
    case installment
    
    var alertMessage: String {
        switch self {
        case .general:
            return "거래내역을 삭제하시겠습니까?\n이 동작은 되돌릴 수 없습니다."
        case .installment:
            return "할부내역 전체가 삭제됩니다. 삭제하시겠습니까?\n이 동작은 되돌릴 수 없습니다."
        }
    }
}

class TransactionManager {
    static let shared = TransactionManager()
    private init() {}
    
    @discardableResult
    func addTransaction(with input: TransactionModel, shouldSave: Bool) -> Transaction {
        
        let transaction = Transaction(context: CoreDataManager.shared.context)
        transaction.amount = input.amount
        transaction.date = input.date
        transaction.id = UUID()
        transaction.isIncome = input.isIncome
        transaction.name = input.name
        transaction.memo = input.memo
        transaction.category = input.category
        transaction.asset = input.asset
        
        let amount = input.amount * (input.isIncome ? 1 : -1)
        let isCompleted = input.asset.type != AssetType.creditCard.rawValue
        
        adjustBalance(amount: amount, asset: input.asset, isCompleted: isCompleted)
        
        if shouldSave {
            CoreDataManager.shared.saveContext()
        }
        
        return transaction
    }
    
    //할부 거래 생성용
    func duplicateTransaction(_ tx: Transaction, count: Int16) -> [Transaction] {
        var txs = [tx]
        for i in 1..<Int(count) {
            let input = TransactionModel(amount: tx.amount, date: Calendar.current.date(byAdding: .month, value: i, to: tx.date)!, isIncome: tx.isIncome, name: tx.name, memo: tx.memo, category: tx.category, asset: tx.asset)
            txs.append(addTransaction(with: input, shouldSave: false))
        }
        return txs
    }
    
    func updateTransaction(_ tx: Transaction, name: String, amount: Int64, memo: String) {
        let isIncome = tx.isIncome
        let (oldAmount, newAmount) = (tx.amount * (isIncome ? 1 : -1), amount * (isIncome ? 1 : -1))
        let asset = tx.asset
        
        tx.name = name
        tx.amount = amount
        tx.memo = memo
        
        adjustBalance(amount: newAmount - oldAmount, asset: asset, isCompleted: tx.isCompleted)
        
        CoreDataManager.shared.saveContext()
    }

    func deleteTransaction(_ transaction: Transaction) {
        // 할부 거래 중 일부를 삭제하려고 하면 → 전체 할부 삭제
        for tx in transaction.installment?.transactions.array as? [Transaction] ?? [transaction] {
            let (amount, asset) = (tx.amount * (tx.isIncome ? 1 : -1), tx.asset)
            adjustBalance(amount: -amount, asset: asset, isCompleted: tx.isCompleted)
            CoreDataManager.shared.context.delete(tx)
        }
        CoreDataManager.shared.saveContext()
    }
    
    func adjustBalance(amount: Int64, asset: AssetItem, isCompleted: Bool) {
        guard isCompleted else { return }
        switch asset {
        case let cash as CashItem:
            cash.balance += amount
        case let bank as BankAccountItem:
            bank.balance += amount
        case let debit as DebitCardItem:
            if let account = debit.linkedAccount {
                account.balance += amount
            } else {
                AssetItemManager.shared.cash[0].balance += amount
            }
        case let credit as CreditCardItem:
            if let account = credit.linkedAccount {
                account.balance += amount
            } else {
                AssetItemManager.shared.cash[0].balance += amount
            }
        default:
            return
        }
    }
}
