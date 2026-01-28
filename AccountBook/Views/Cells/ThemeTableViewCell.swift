//
//  ThemeTableViewCell.swift
//  AccountBook
//
//  Created by 김정원 on 12/1/25.
//

import UIKit

class ThemeTableViewCell: UITableViewCell {
    @IBOutlet weak var colorView: UIView!
    @IBOutlet weak var checkView: UIView!
    
    var model: AppTheme! {
        didSet {
            configure()
        }
    }
    
    func configure() {
        colorView.backgroundColor = model.accentColor
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        checkView.backgroundColor = selected ? model.accentColor : UIColor.systemBackground
    }
}
