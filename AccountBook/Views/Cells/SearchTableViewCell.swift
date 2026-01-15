//
//  SearchTableViewCell.swift
//  AccountBook
//
//  Created by 김정원 on 1/14/26.
//

import UIKit

class SearchTableViewCell: UITableViewCell {

    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var categoryImageView: UIImageView!
    @IBOutlet weak var categoryNameLabel: UILabel!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var memoLabel: UILabel!
    @IBOutlet weak var amountLabel: UILabel!
    @IBOutlet weak var assetLabel: UILabel!
    
    var viewModel: SearchCellViewModel! {
        didSet {
            configure()
        }
    }
    
    func configure() {
        dateLabel.text = viewModel.dateDisplay
        categoryImageView.image = viewModel.categoryImageName.toImage()
        categoryNameLabel.text = viewModel.categoryName
        nameLabel.text = viewModel.name
        memoLabel.text = viewModel.memo + " "
        amountLabel.text = viewModel.amountDisplay
        assetLabel.text = viewModel.assetDisplay
    }
    
}
