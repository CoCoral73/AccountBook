//
//  CategoryViewModel.swift
//  AccountBook
//
//  Created by 김정원 on 7/16/25.
//

import UIKit

class CategoryCellViewModel {
    
    //nil -> 추가 셀
    private var category: Category?
    
    init(category: Category?) {
        self.category = category
    }
    
    var image: UIImage {
        guard let category = category else { return UIImage(systemName: "plus")! }
        return category.iconName.toImage()!
    }
    var nameString: String {
        guard let category = category else { return "추가" }
        return category.name
    }
    
}
