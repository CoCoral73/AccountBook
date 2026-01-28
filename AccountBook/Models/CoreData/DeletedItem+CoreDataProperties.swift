//
//  DeletedItem+CoreDataProperties.swift
//  
//
//  Created by 김정원 on 1/28/26.
//
//

import Foundation
import CoreData


extension DeletedItem {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<DeletedItem> {
        return NSFetchRequest<DeletedItem>(entityName: "DeletedItem")
    }


}
