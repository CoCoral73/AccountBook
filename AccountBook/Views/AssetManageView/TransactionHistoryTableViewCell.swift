//
//  TransactionHistoryTableViewCell.swift
//  AccountBook
//
//  Created by 김정원 on 1/7/26.
//

import UIKit

class TransactionHistoryTableViewCell: UITableViewCell {

    @IBOutlet weak var typeView: UIView!
    @IBOutlet weak var typeLabel: UILabel!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var categoryLabel: UILabel!
    @IBOutlet weak var amountLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    
    var viewModel: HistoryCellViewModel! {
        didSet {
            configure()
        }
    }
    
    func configure() {
        typeLabel.text = viewModel.typeName
        nameLabel.text = viewModel.name
        categoryLabel.text = viewModel.categoryName
        amountLabel.text = viewModel.amountDisplay
        dateLabel.text = viewModel.dateDisplay
    }

}
