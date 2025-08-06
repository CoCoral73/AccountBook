//
//  AssetTableViewCell.swift
//  AccountBook
//
//  Created by 김정원 on 8/6/25.
//

import UIKit

class AssetTableViewCell: UITableViewCell {

    @IBOutlet weak var nameLabel: UILabel!
    
    var viewModel: AssetViewModel! {
        didSet {
            configure()
        }
    }
    
//    override func awakeFromNib() {
//        super.awakeFromNib()
//        // Initialization code
//    }
//
//    override func setSelected(_ selected: Bool, animated: Bool) {
//        super.setSelected(selected, animated: animated)
//
//        // Configure the view for the selected state
//    }

    func configure() {
        nameLabel.text = viewModel.nameString
    }
}
