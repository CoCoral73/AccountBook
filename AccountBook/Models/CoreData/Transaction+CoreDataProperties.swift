//
//  Transaction+CoreDataProperties.swift
//  AccountBook
//
//  Created by 김정원 on 8/14/25.
//
//

import Foundation
import CoreData


extension Transaction {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Transaction> {
        return NSFetchRequest<Transaction>(entityName: "Transaction")
    }

    @NSManaged public var amount: Int64
    @NSManaged public var date: Date
    @NSManaged public var id: UUID
    @NSManaged public var isIncome: Bool
    @NSManaged public var name: String
    @NSManaged public var memo: String
    @NSManaged public var asset: AssetItem
    @NSManaged public var category: Category

}

extension Transaction : Identifiable {

}
