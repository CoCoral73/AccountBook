//
//  AppTheme.swift
//  AccountBook
//
//  Created by 김정원 on 11/17/25.
//
import UIKit

enum AppThemeKind: String, CaseIterable {
    case pink
    case orange
    case yellow
    case green
    case blue
    case purple
    case gray
    
    var theme: AppTheme {
        switch self {
        case .pink:
            return PinkTheme()
        case .orange:
            return OrangeTheme()
        case .yellow:
            return YellowTheme()
        case .green:
            return GreenTheme()
        case .blue:
            return BlueTheme()
        case .purple:
            return PurpleTheme()
        case .gray:
            return GrayTheme()
        }
    }
}

protocol AppTheme {
    var baseColor: UIColor { get }
    var accentColor: UIColor { get }

    var primaryTextColor: UIColor { get }
    var secondaryTextColor: UIColor { get }
    var pointTextColor: UIColor { get }
    var incomeTextColor: UIColor { get }
    var expenseTextColor: UIColor { get }
    
    var chartColors: [UIColor] { get }
    var sectionColors: [UIColor] { get }
    var calendarColors: [UIColor] { get }
}

extension AppTheme {
    var primaryTextColor: UIColor { .label }
    var secondaryTextColor: UIColor { .secondaryLabel }
    var pointTextColor: UIColor { UIColor(red: 0.85, green: 0.11, blue: 0.38, alpha: 1.0) }
    var incomeTextColor: UIColor { UIColor(red: 0.18, green: 0.55, blue: 0.37, alpha: 1.00) }
    var expenseTextColor: UIColor { UIColor(red: 0.76, green: 0.24, blue: 0.27, alpha: 1.00) }
    
    var chartColors: [UIColor] {
        [
            //빨 주 노 초 하 파 보 쿨핑 핑 회
            UIColor(red: 1.00, green: 0.64, blue: 0.64, alpha: 1.00),
            UIColor(red: 1.00, green: 0.75, blue: 0.64, alpha: 1.00),
            UIColor(red: 1.00, green: 0.88, blue: 0.64, alpha: 1.00),
            UIColor(red: 0.77, green: 1.00, blue: 0.64, alpha: 1.00),
            UIColor(red: 0.64, green: 1.00, blue: 0.99, alpha: 1.00),
            UIColor(red: 0.64, green: 0.84, blue: 1.00, alpha: 1.00),
            UIColor(red: 0.80, green: 0.64, blue: 1.00, alpha: 1.00),
            UIColor(red: 1.00, green: 0.68, blue: 0.96, alpha: 1.00),
            UIColor(red: 1.00, green: 0.78, blue: 0.78, alpha: 1.00),
            UIColor(red: 0.85, green: 0.85, blue: 0.85, alpha: 1.00)
        ]
    }
    var sectionColors: [UIColor] {
        [chartColors[0], chartColors[2], chartColors[3], chartColors[4]]
    }
    var calendarColors: [UIColor] {
        [.systemGray, .systemRed, .label, .label, .label, .label, .label, .systemBlue ]
    }
}
