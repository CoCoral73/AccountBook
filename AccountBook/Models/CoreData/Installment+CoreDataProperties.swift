//
//  Installment+CoreDataProperties.swift
//  AccountBook
//
//  Created by 김정원 on 9/3/25.
//
//

import Foundation
import CoreData


extension Installment {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Installment> {
        return NSFetchRequest<Installment>(entityName: "Installment")
    }

    @NSManaged public var id: UUID
    @NSManaged public var numberOfMonths: Int16
    @NSManaged public var transactions: NSOrderedSet

    var totalAmount: Int64 {
        let transactions = transactions.array as? [Transaction] ?? []
        return transactions.reduce(0) { $0 + $1.amount }
    }
}

extension Installment : Identifiable {

}
