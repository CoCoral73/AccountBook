//
//  CalendarCollectionViewCell.swift
//  AccountBook
//
//  Created by 김정원 on 7/2/25.
//

import UIKit

struct DayItem: Hashable {
    let id: UUID    //ItemIdentifierType
    let date: Date
    var income, expense: Int64
}

class CalendarCollectionViewCell: UICollectionViewCell, ThemeApplicable {
    
    @IBOutlet weak var dayLabel: UILabel!
    
    @IBOutlet weak var incomeLabel: UILabel!
    @IBOutlet weak var expenseLabel: UILabel!
    
    var viewModel: CalendarCellViewModel! {
        didSet {
            configure()
            applyTheme(ThemeManager.shared.currentTheme)
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleThemeChange),
            name: .themeDidChange,
            object: nil
        )
        
        applyStaticTheme(ThemeManager.shared.currentTheme)
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        contentView.backgroundColor = .clear
    }
    
    @objc private func handleThemeChange() {
        applyStaticTheme(ThemeManager.shared.currentTheme)
        if viewModel != nil { applyTheme(ThemeManager.shared.currentTheme)}
    }
    
    func configure() {
        let (day, _) = viewModel.dayStringAndWeekday
        
        dayLabel.text = day
        incomeLabel.text = viewModel.incomeString
        expenseLabel.text = viewModel.expenseString
        
        viewModel.onSelectionChanged = { [weak self] isSelected in
            self?.contentView.backgroundColor = isSelected ? ThemeManager.shared.currentTheme.baseColor : .clear
        }
    }
    
    func applyStaticTheme(_ theme: AppTheme) {
        incomeLabel.textColor = theme.incomeTextColor
        expenseLabel.textColor = theme.expenseTextColor
    }
    
    func applyTheme(_ theme: AppTheme) {
        let (_, weekday) = viewModel.dayStringAndWeekday
        dayLabel.textColor = theme.calendarColors[weekday]
        viewModel.isSelected = viewModel.isSelected     //셀 배경색 트리거
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}
