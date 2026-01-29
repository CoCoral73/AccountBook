//
//  SearchCellViewModel.swift
//  AccountBook
//
//  Created by 김정원 on 1/14/26.
//

import Foundation

class SearchCellViewModel {
    var transaction: Transaction
    
    init(transaction: Transaction) {
        self.transaction = transaction
    }
    
    var dateDisplay: String {
        let fmt = DateFormatter()
        fmt.dateFormat = "yyyy.MM.dd"
        return fmt.string(from: transaction.date)
    }
    var categoryImageName: String {
        return transaction.category.iconName
    }
    var categoryName: String {
        return transaction.category.name
    }
    var name: String {
        return transaction.name
    }
    var memo: String {
        return transaction.memo
    }
    var amountDisplay: String {
        return transaction.amount.formattedWithComma + "원"
    }
    var assetDisplay: String {
        switch transaction.type {
        case .income, .expense:
            return transaction.asset?.name ?? "(알 수 없음)"
        case .transfer:
            let fromAccount = transaction.fromAccount?.name ?? "(알 수 없음)"
            let toAccount = transaction.toAccount?.name ?? "(알 수 없음)"
            return "\(fromAccount) → \(toAccount)"
        }
    }
    
}
