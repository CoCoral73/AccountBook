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

    @NSManaged public var totalAmount: Int64
    @NSManaged public var numberOfMonths: Int16
    @NSManaged public var transaction: Transaction

    var monthlyAmount: Int64 {
        return totalAmount / Int64(numberOfMonths)
    }
}

extension Installment : Identifiable {

}
