//
//  AssetTypeTableViewCell.swift
//  AccountBook
//
//  Created by 김정원 on 1/8/26.
//

import UIKit

class AssetTypeTableViewCell: UITableViewCell {

    @IBOutlet weak var nameLabel: UILabel!
    
    var model: AssetType! {
        didSet {
            configure()
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        let backView = UIView()
        backView.backgroundColor = ThemeManager.shared.currentTheme.baseColor
        self.selectedBackgroundView = backView
    }
    
    func configure() {
        nameLabel.text = model.displayName
    }
}
