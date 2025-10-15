//
//  DetailTableViewCell.swift
//  AccountBook
//
//  Created by 김정원 on 7/3/25.
//

import UIKit

class TransactionDetailTableViewCell: UITableViewCell {
    
    @IBOutlet weak var imgView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var categoryLabel: UILabel!
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var assetItemLabel: UILabel!
    
    var viewModel: TransactionDetailViewModel! {
        didSet {
            configure()
        }
    }
    
    func configure() {
        imgView.image = viewModel.image
        nameLabel.text = viewModel.nameString
        categoryLabel.text = viewModel.categoryString
        priceLabel.text = viewModel.priceString
        assetItemLabel.text = viewModel.assetItemString
    }

}
