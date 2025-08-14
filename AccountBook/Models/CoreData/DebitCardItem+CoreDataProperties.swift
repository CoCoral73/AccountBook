//
//  DebitCardItem+CoreDataProperties.swift
//  AccountBook
//
//  Created by 김정원 on 8/14/25.
//
//

import Foundation
import CoreData


extension DebitCardItem {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<DebitCardItem> {
        return NSFetchRequest<DebitCardItem>(entityName: "DebitCardItem")
    }

    @NSManaged public var linkedAccount: BankAccountItem?

}
