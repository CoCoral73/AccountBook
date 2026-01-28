//
//  HistoryCellViewModel.swift
//  AccountBook
//
//  Created by 김정원 on 1/7/26.
//

import Foundation

class HistoryCellViewModel {
    var transaction: Transaction
    var asset: AssetItem
    
    init(transaction: Transaction, asset: AssetItem) {
        self.transaction = transaction
        self.asset = asset
    }
    
    var typeName: String {
        return transaction.type.name
    }
    var name: String {
        if transaction.type != .transfer { return transaction.name }
        
        let suffix: String
        if transaction.fromAccount == asset as? BankAccountItem {
            suffix = "(→ \(transaction.toAccount?.name ?? "알 수 없음"))"
        } else {
            suffix = "(\(transaction.fromAccount?.name ?? "알 수 없음") →)"
        }
        return [transaction.name, suffix].filter { !$0.isEmpty }.joined(separator: " ")
    }
    var categoryName: String {
        return transaction.category.name
    }
    var amountDisplay: String {
        let amountString = transaction.amount.formattedWithComma
        switch transaction.type {
        case .income:
            return "+" + amountString
        case .expense:
            return "-" + amountString
        case .transfer:
            if transaction.fromAccount == asset as? BankAccountItem {
                return "-" + amountString
            } else {
                return "+" + amountString
            }
        }
    }
    var dateDisplay: String {
        let fmt = DateFormatter()
        fmt.dateFormat = "yyyy.MM.dd"
        return fmt.string(from: transaction.date)
    }
}
