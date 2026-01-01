//
//  AssetInfoTableViewHeaderView.swift
//  AccountBook
//
//  Created by 김정원 on 11/5/25.
//

import UIKit

class AssetInfoTableViewHeaderView: UITableViewHeaderFooterView {

    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var amountLabel: UILabel!
    
    func configure(_ name: String, _ amount: String) {
        nameLabel.text = name
        amountLabel.text = amount
    }
}
