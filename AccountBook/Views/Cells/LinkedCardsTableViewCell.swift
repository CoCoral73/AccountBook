//
//  LinkedCardsTableViewCell.swift
//  AccountBook
//
//  Created by 김정원 on 11/12/25.
//

import UIKit

class LinkedCardsTableViewCell: UITableViewCell {
    
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var cardTypeLabel: UILabel!
    
    var model: AssetItem! {
        didSet {
            configure()
        }
    }

    func configure() {
        nameLabel.text = model.name
        cardTypeLabel.text = AssetType(rawValue: Int(model.type))!.displayName
    }

}
