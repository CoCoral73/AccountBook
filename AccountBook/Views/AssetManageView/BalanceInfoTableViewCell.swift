//
//  AssetManageTableViewCell.swift
//  AccountBook
//
//  Created by 김정원 on 11/5/25.
//

import UIKit

class BalanceInfoTableViewCell: UITableViewCell {

    @IBOutlet weak var backView: UIView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var amountLabel: UILabel!
    
    var viewModel: BalanceInfoTableViewCellViewModel! {
        didSet {
            configure()
        }
    }
    
    func configure() {
        nameLabel.text = viewModel.nameString
        amountLabel.text = viewModel.amountString
    }
    
    override func layoutSubviews() {
        // 그림자 설정
        backView.layer.cornerRadius = 12
        backView.layer.shadowColor = UIColor.black.cgColor
        backView.layer.shadowOpacity = 0.2
        backView.layer.shadowOffset = CGSize(width: 2, height: 2)
        backView.layer.shadowRadius = 4

        // ⚠️ 성능 & 정확도 위해 shadowPath 설정 (권장)
        backView.layer.shadowPath = UIBezierPath(
            roundedRect: backView.bounds,
            cornerRadius: backView.layer.cornerRadius
        ).cgPath
    }
}
