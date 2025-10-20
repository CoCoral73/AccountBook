//
//  AssetSectionHeaderView.swift
//  AccountBook
//
//  Created by 김정원 on 10/20/25.
//

import UIKit

class AssetSectionHeaderView: UITableViewHeaderFooterView {
    @IBOutlet weak var pointBar: UIView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var amountLabel: UILabel!
    
    private let color: [UIColor] = [chartColors[0], chartColors[2], chartColors[3], chartColors[4]]
    
    func configure(_ section: Int, _ name: String, _ amount: String) {
        pointBar.backgroundColor = color[section]
        nameLabel.text = name
        amountLabel.text = amount
    }
}
