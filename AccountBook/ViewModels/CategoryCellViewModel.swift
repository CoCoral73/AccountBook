//
//  CategoryViewModel.swift
//  AccountBook
//
//  Created by 김정원 on 7/16/25.
//

import UIKit

class CategoryCellViewModel {
    
    private var category: Category
    
    init(category: Category) {
        self.category = category
    }
    
    var image: UIImage {
        return category.iconName.toImage()!
    }
    var nameString: String {
        return category.name
    }
    
}
