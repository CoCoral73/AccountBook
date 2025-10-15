//
//  AssetTableViewCell.swift
//  AccountBook
//
//  Created by 김정원 on 8/6/25.
//

import UIKit

class AssetItemTableViewCell: UITableViewCell {

    @IBOutlet weak var nameLabel: UILabel!
    
    var model: AssetItem? {
        didSet {
            configure()
        }
    }

    func configure() {
        nameLabel.text = model?.name ?? "자산 추가"
    }
}
