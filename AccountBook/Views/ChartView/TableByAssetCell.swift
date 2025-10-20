//
//  TableByAssetCell.swift
//  AccountBook
//
//  Created by 김정원 on 10/20/25.
//

import UIKit

class TableByAssetCell: UITableViewCell {
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var amountLabel: UILabel!
    
    func configure(_ name: String, _ amount: String) {
        nameLabel.text = name
        amountLabel.text = amount
    }
}
