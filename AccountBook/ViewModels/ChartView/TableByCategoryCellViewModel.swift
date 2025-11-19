//
//  ChartByCategoryCellViewModel.swift
//  AccountBook
//
//  Created by 김정원 on 10/15/25.
//

import Foundation

class TableByCategoryCellViewModel {
    var category: Category
    var amount: Double, total: Double
    
    init(category: Category, amount: Double, total: Double) {
        self.category = category
        self.amount = amount
        self.total = total
    }
    
    var imageName: String {
        category.iconName
    }
    var nameString: String {
        category.name
    }
    var ratio: Double {
        amount / total
    }
    var ratioString: String {
        let fmt = NumberFormatter()
        fmt.numberStyle = .decimal
        fmt.minimumFractionDigits = 1
        fmt.maximumFractionDigits = 1
        fmt.roundingMode = .halfUp
        return (fmt.string(from: NSNumber(value: ratio * 100)) ?? "0") + "%"
    }
    var amountString: String {
        Int64(amount).formattedWithComma + "원"
    }
}
