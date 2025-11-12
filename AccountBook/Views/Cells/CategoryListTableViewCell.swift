//
//  CategoryListTableViewCell.swift
//  AccountBook
//
//  Created by 김정원 on 11/12/25.
//

import UIKit

class CategoryListTableViewCell: UITableViewCell {

    @IBOutlet weak var iconImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    
    var model: Category! {
        didSet {
            configure()
        }
    }
    
    func configure() {
        iconImageView.image = model.iconName.toImage()!
        nameLabel.text = model.name
    }

}
