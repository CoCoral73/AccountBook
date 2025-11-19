//
//  ChartByCategoryTableViewCell.swift
//  AccountBook
//
//  Created by 김정원 on 10/14/25.
//

import UIKit

class TableByCategoryCell: UITableViewCell {

    @IBOutlet weak var categoryImgView: UIImageView!
    @IBOutlet weak var categoryNameLabel: UILabel!
    @IBOutlet weak var percenBar: UIView!
    @IBOutlet weak var widthRatioConstraint: NSLayoutConstraint!
    @IBOutlet weak var percentLabel: UILabel!
    @IBOutlet weak var amountLabel: UILabel!
    
    var viewModel: TableByCategoryCellViewModel! {
        didSet {
            configureUI()
        }
    }
    
    func configureUI() {
        categoryImgView.image = viewModel.imageName.toImage()
        categoryNameLabel.text = viewModel.nameString
        updateBarWidth(ratio: viewModel.ratio)
        percentLabel.text = viewModel.ratioString
        amountLabel.text = viewModel.amountString
    }
    
    func updateBarWidth(ratio: CGFloat) {
        

        let newConstraint = NSLayoutConstraint(
            item: widthRatioConstraint.firstItem as Any,
            attribute: widthRatioConstraint.firstAttribute,
            relatedBy: widthRatioConstraint.relation,
            toItem: widthRatioConstraint.secondItem,
            attribute: widthRatioConstraint.secondAttribute,
            multiplier: ratio,
            constant: widthRatioConstraint.constant
        )

        NSLayoutConstraint.deactivate([widthRatioConstraint])
        NSLayoutConstraint.activate([newConstraint])
        widthRatioConstraint = newConstraint

        layoutIfNeeded()
    }

}
