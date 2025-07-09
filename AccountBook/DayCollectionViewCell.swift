//
//  CalendarCollectionViewCell.swift
//  AccountBook
//
//  Created by 김정원 on 7/2/25.
//

import UIKit

struct DayItem: Hashable {
    let index: Int
    let date: Date
    let income, expense: Int64
    
    /* index로만 식별
    func hash(into hasher: inout Hasher) {
        hasher.combine(index)
    }
    static func == (lhs: DayItem, rhs: DayItem) -> Bool {
        lhs.index == rhs.index
    }
     */
}

class DayCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var dayLabel: UILabel!
    
    @IBOutlet weak var incomeLabel: UILabel!
    @IBOutlet weak var expenseLabel: UILabel!
    
    var viewModel: DayViewModel! {
        didSet {
            configure()
        }
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()

        viewModel.onSelectionChanged = nil
        contentView.backgroundColor = .clear
    }
    
    func configure() {
        let dayStringAndColor = viewModel.dayStringAndColor
        dayLabel.text = dayStringAndColor.text
        dayLabel.textColor = dayStringAndColor.color
        
        incomeLabel.text = viewModel.incomeString
        incomeLabel.textColor = viewModel.incomeTextColor
        expenseLabel.text = viewModel.expenseString
        expenseLabel.textColor = viewModel.expenseTextColor
        
        contentView.backgroundColor = .clear
        
        viewModel.onSelectionChanged = { [weak self] isSelected in
            self?.contentView.backgroundColor = isSelected ? #colorLiteral(red: 1, green: 0.5680983663, blue: 0.6200271249, alpha: 0.2426014073) : .clear
        }
    }
}
