//
//  Category+CoreDataProperties.swift
//  AccountBook
//
//  Created by 김정원 on 8/14/25.
//
//

import Foundation
import CoreData


extension Category {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Category> {
        return NSFetchRequest<Category>(entityName: "Category")
    }

    @NSManaged public var iconName: String
    @NSManaged public var id: UUID
    @NSManaged public var isIncome: Bool
    @NSManaged public var name: String
    @NSManaged public var transactions: NSSet?

}

// MARK: Generated accessors for transactions
extension Category {

    @objc(addTransactionsObject:)
    @NSManaged public func addToTransactions(_ value: Transaction)

    @objc(removeTransactionsObject:)
    @NSManaged public func removeFromTransactions(_ value: Transaction)

    @objc(addTransactions:)
    @NSManaged public func addToTransactions(_ values: NSSet)

    @objc(removeTransactions:)
    @NSManaged public func removeFromTransactions(_ values: NSSet)

}

extension Category : Identifiable {

}
