//
//  CategoryViewModel.swift
//  AccountBook
//
//  Created by 김정원 on 7/16/25.
//

import UIKit

class CategoryViewModel {
    
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

extension String {
    func toImage(withDimension dimension: CGFloat = 40, scale: CGFloat = UIScreen.main.scale) -> UIImage? {
        // Create a UILabel to hold the emoji
        let label = UILabel()
        label.text = self // Set the emoji as the label's text
        label.font = UIFont.systemFont(ofSize: dimension) // Set a large font size for clarity
        label.sizeToFit() // Adjust label size to fit the content

        // Begin an image context with the label's bounds and the desired scale
        UIGraphicsBeginImageContextWithOptions(label.bounds.size, false, scale)

        // Render the label's layer into the current image context
        guard let context = UIGraphicsGetCurrentContext() else { return nil }
        label.layer.render(in: context)

        // Get the image from the context
        let image = UIGraphicsGetImageFromCurrentImageContext()

        // End the image context
        UIGraphicsEndImageContext()

        return image
    }
}
