//
//  AssetManageForCreditCardTableViewCell.swift
//  AccountBook
//
//  Created by 김정원 on 11/5/25.
//

import UIKit

class AssetManageTableViewForCreditCardCell: UITableViewCell {

    @IBOutlet weak var backView: UIView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var currentMonthSpendingLabel: UILabel!
    @IBOutlet weak var upcomingPaymentAmountLabel: UILabel!
    
    var viewModel: AssetManageForCreditCardCellViewModel! {
        didSet {
            configure()
        }
    }
    
    func configure() {
        nameLabel.text = viewModel.nameString
        currentMonthSpendingLabel.text = viewModel.currentMonthSpendingString
        upcomingPaymentAmountLabel.text = viewModel.upcomingPaymentAmountString
    }
}
