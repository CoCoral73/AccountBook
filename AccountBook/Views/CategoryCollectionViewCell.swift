//
//  CategoryCollectionViewCell.swift
//  AccountBook
//
//  Created by 김정원 on 7/16/25.
//

import UIKit

class CategoryCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var imgView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    
    var viewModel: CategoryCellViewModel! {
        didSet {
            configure()
        }
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()

        imgView.image = nil
        nameLabel.text = ""
    }
    
    func configure() {
        imgView.image = viewModel.image
        nameLabel.text = viewModel.nameString
    }
    
}
