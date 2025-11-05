//
//  AssetManageTableViewCell.swift
//  AccountBook
//
//  Created by 김정원 on 11/5/25.
//

import UIKit

class AssetManageTableViewForNotCreditCardCell: UITableViewCell {

    @IBOutlet weak var backView: UIView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var amountLabel: UILabel!
    
    var viewModel: AssetManageForNotCreditCardCellViewModel! {
        didSet {
            configure()
        }
    }
    
    func configure() {
        nameLabel.text = viewModel.nameString
        amountLabel.text = viewModel.amountString
    }
}
