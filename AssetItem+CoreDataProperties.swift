//
//  AssetItem+CoreDataProperties.swift
//  AccountBook
//
//  Created by 김정원 on 8/14/25.
//
//

import Foundation
import CoreData


extension AssetItem {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<AssetItem> {
        return NSFetchRequest<AssetItem>(entityName: "AssetItem")
    }

    @NSManaged public var id: UUID
    @NSManaged public var name: String
    @NSManaged public var transactions: NSSet?

}

// MARK: Generated accessors for transactions
extension AssetItem {

    @objc(addTransactionsObject:)
    @NSManaged public func addToTransactions(_ value: Transaction)

    @objc(removeTransactionsObject:)
    @NSManaged public func removeFromTransactions(_ value: Transaction)

    @objc(addTransactions:)
    @NSManaged public func addToTransactions(_ values: NSSet)

    @objc(removeTransactions:)
    @NSManaged public func removeFromTransactions(_ values: NSSet)

}

extension AssetItem : Identifiable {

}
