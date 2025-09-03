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
        newInstallment.totalAmount = transaction.amount
        newInstallment.numberOfMonths = period
        newInstallment.transaction = transaction
        
        CoreDataManager.shared.saveContext()
    }
    
    func updateInstallment(with installment: Installment, period: Int16) {
        installment.numberOfMonths = period
        
        CoreDataManager.shared.saveContext()
    }
    func updateInstallment(with installment: Installment, totalAmount: Int64) {
        installment.totalAmount = totalAmount
        
        CoreDataManager.shared.saveContext()
    }
    
    func deleteInstallment(_ transaction: Transaction) {
        guard let installment = transaction.installment else { return }
        CoreDataManager.shared.context.delete(installment)
        CoreDataManager.shared.saveContext()
    }
}
