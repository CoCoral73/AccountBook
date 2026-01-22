//
//  FilterTableViewCell.swift
//  AccountBook
//
//  Created by 김정원 on 1/19/26.
//

import UIKit

class FilterTableViewCell: UITableViewCell {
    
    @IBOutlet weak var iconView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var checkView: UIImageView!
    
    var viewModel: FilterCellViewModel! {
        didSet {
            configure()
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(didTapCheckView))
        checkView.addGestureRecognizer(tap)
    }
    
    func configure() {
        iconView.isHidden = viewModel.isIconViewHidden
        iconView.image = viewModel.iconName?.toImage()
        nameLabel.text = viewModel.name
        checkView.image = UIImage(systemName: viewModel.checkImageName)
    }
    
    @objc func didTapCheckView() {
        viewModel.isCheck.toggle()
        checkView.image = UIImage(systemName: viewModel.checkImageName)
    }
}
