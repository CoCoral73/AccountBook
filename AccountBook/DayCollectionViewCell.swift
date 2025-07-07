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
    
    func configure() {
        let dayStringAndColor = viewModel.dayStringAndColor
        dayLabel.text = dayStringAndColor.text
        dayLabel.textColor = dayStringAndColor.color
        
        incomeLabel.text = viewModel.incomeString
        incomeLabel.textColor = viewModel.incomeTextColor
        expenseLabel.text = viewModel.expenseString
        expenseLabel.textColor = viewModel.expenseTextColor
    }
}
