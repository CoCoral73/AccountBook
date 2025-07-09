//
//  DetailViewModel.swift
//  AccountBook
//
//  Created by 김정원 on 7/8/25.
//

import UIKit

class DetailViewModel {
    
    private var transaction: Transaction
    
    init(transaction: Transaction) {
        self.transaction = transaction
    }
    
    var image: UIImage? {
        UIImage(systemName: "cart")
    }
    var nameString: String? {
        return transaction.memo
    }
    var categoryString: String {
        return transaction.category.name
    }
    var priceString: String {
        return "+\(transaction.amount)원"
    }
    var paymentString: String {
        return "삼성카드"
    }
}
