//
//  Transaction+CoreDataProperties.swift
//  AccountBook
//
//  Created by 김정원 on 9/3/25.
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
    @NSManaged public var memo: String
    @NSManaged public var name: String
    @NSManaged public var asset: AssetItem
    @NSManaged public var category: Category
    @NSManaged public var installment: Installment?
    @NSManaged public var installmentIndex: NSNumber?
    
    var installmentIndexValue: Int16?
    {
        get { installmentIndex?.int16Value }
    }
}

extension Transaction : Identifiable {

}
