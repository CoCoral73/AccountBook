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
    @IBOutlet weak var signedAmountLabel: UILabel!
    @IBOutlet weak var assetLabel: UILabel!
    
    var viewModel: TransactionDetailViewModel! {
        didSet {
            configure()
        }
    }
    
    func configure() {
        imgView.image = viewModel.imageName.toImage()
        nameLabel.text = viewModel.transactionName
        categoryLabel.text = viewModel.categoryName
        signedAmountLabel.text = viewModel.signedAmountDisplay
        assetLabel.text = viewModel.assetName
    }

}
