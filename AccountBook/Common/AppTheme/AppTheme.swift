//
//  AppTheme.swift
//  AccountBook
//
//  Created by 김정원 on 11/17/25.
//
import UIKit

protocol AppTheme {
    var baseColor: UIColor { get }
    var primaryTextColor: UIColor { get }
    var secondaryTextColor: UIColor { get }
    var accentColor: UIColor { get }

    var incomeTextColor: UIColor { get }
    var expenseTextColor: UIColor { get }
    
    var chartColors: [UIColor] { get }
}
