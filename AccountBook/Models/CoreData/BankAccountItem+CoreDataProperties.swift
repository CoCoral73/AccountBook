//
//  BankAccountItem+CoreDataProperties.swift
//  AccountBook
//
//  Created by 김정원 on 8/14/25.
//
//

import Foundation
import CoreData


extension BankAccountItem {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<BankAccountItem> {
        return NSFetchRequest<BankAccountItem>(entityName: "BankAccountItem")
    }

    @NSManaged public var balance: Int64
    @NSManaged public var linkedCreditCards: NSSet?
    @NSManaged public var linkedDebitCards: NSSet?
}
