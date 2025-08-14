//
//  CashItem+CoreDataProperties.swift
//  AccountBook
//
//  Created by 김정원 on 8/14/25.
//
//

import Foundation
import CoreData


extension CashItem {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<CashItem> {
        return NSFetchRequest<CashItem>(entityName: "CashItem")
    }

}
