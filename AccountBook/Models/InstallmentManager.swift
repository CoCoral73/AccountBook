//
//  InstallmentManager.swift
//  AccountBook
//
//  Created by 김정원 on 9/3/25.
//

import Foundation

class InstallmentManager {
    static let shared = InstallmentManager()
    private init() { }
    
    func addInstallment(_ transaction: Transaction, period: Int16) {
        let newInstallment = Installment(context: CoreDataManager.shared.context)
        newInstallment.id = UUID()
        newInstallment.numberOfMonths = period
        
        let txs: [Transaction] = TransactionManager.shared.duplicateTransaction(transaction, count: period)
        let monthlyAmounts = calculateMonthlyAmount(total: transaction.amount, period: period)
        for i in 0..<Int(period) {
            txs[i].amount = monthlyAmounts[i]
            txs[i].installment = newInstallment
            txs[i].installmentIndex = NSNumber(value: i + 1)
        }
        
        CoreDataManager.shared.saveContext()
        NotificationCenter.default.post(name: .txDidUpdate, object: nil, userInfo: ["date": transaction.date])
    }
    
    func calculateMonthlyAmount(total: Int64, period: Int16) -> [Int64] {
        let period = Int64(period)
        var monthlyAmounts = (0..<period).map { _ in return total / period }
        monthlyAmounts[0] += total % period
        return monthlyAmounts
    }
    
    func deleteInstallment(_ transaction: Transaction) {
        guard let installment = transaction.installment else {
            print("할부 제거: 할부가 존재하지 않음")
            return
        }
        
        let date = transaction.date
        let txs = installment.transactions.array as? [Transaction] ?? []
        txs[0].amount = installment.totalAmount
        txs[0].installment = nil
        txs[0].installmentIndex = nil
        
        for i in 1..<txs.count {
            CoreDataManager.shared.context.delete(txs[i])
        }
        
        CoreDataManager.shared.context.delete(installment)
        CoreDataManager.shared.saveContext()
        NotificationCenter.default.post(name: .txDidUpdate, object: nil, userInfo: ["date": date])
    }
}
