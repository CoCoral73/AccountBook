//
//  CreditCardItem+CoreDataProperties.swift
//  AccountBook
//
//  Created by 김정원 on 8/14/25.
//
//

import Foundation
import CoreData


extension CreditCardItem {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<CreditCardItem> {
        return NSFetchRequest<CreditCardItem>(entityName: "CreditCardItem")
    }

    @NSManaged public var withdrawalDate: Date?
    @NSManaged public var startDate: Date?
    @NSManaged public var linkedAccount: BankAccountItem?

}
