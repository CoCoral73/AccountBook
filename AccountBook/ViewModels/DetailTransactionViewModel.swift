//
//  DetailViewModel.swift
//  AccountBook
//
//  Created by 김정원 on 7/8/25.
//

import UIKit

class DetailTransactionViewModel {
    
    private(set) var transaction: Transaction
    
    init(transaction: Transaction) {
        self.transaction = transaction
    }
    
    var image: UIImage? {
        return transaction.category.iconName.toImage()
    }
    var nameString: String? {
        return transaction.memo
    }
    var categoryString: String {
        return transaction.category.name
    }
    var priceString: String {
        return (transaction.isIncome ? "+" : "-") + "\(transaction.amount.formattedWithComma)원"
    }
    var assetString: String {
        return transaction.asset.name
    }
    
    func setTransaction(with transaction: Transaction) {
        self.transaction = transaction
    }
}
