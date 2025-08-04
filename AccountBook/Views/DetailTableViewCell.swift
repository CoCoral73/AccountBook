//
//  DetailTableViewCell.swift
//  AccountBook
//
//  Created by 김정원 on 7/3/25.
//

import UIKit

class DetailTableViewCell: UITableViewCell {
    
    @IBOutlet weak var imgView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var categoryLabel: UILabel!
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var paymentLabel: UILabel!
    
    var viewModel: DetailViewModel! {
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
        imgView.image = viewModel.image
        nameLabel.text = viewModel.nameString
        categoryLabel.text = viewModel.categoryString
        priceLabel.text = viewModel.priceString
        paymentLabel.text = viewModel.assetString
    }

}
