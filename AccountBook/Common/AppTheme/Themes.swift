//
//  PinkTheme.swift
//  AccountBook
//
//  Created by 김정원 on 11/17/25.
//
import UIKit

//MARK: - Pink
struct PinkTheme: AppTheme {
    //FFEAEA
    var baseColor: UIColor { UIColor(red: 1.00, green: 0.92, blue: 0.92, alpha: 1.00) }
    //FFB9B9
    var accentColor: UIColor { UIColor(red: 1.00, green: 0.73, blue: 0.73, alpha: 1.00) }
    
    var incomeTextColor: UIColor { UIColor(red: 0.23, green: 0.65, blue: 0.36, alpha: 1.00) }
    
    var expenseTextColor: UIColor { UIColor(red: 0.82, green: 0.28, blue: 0.28, alpha: 1.00) }
    
}

//MARK: - Orange
struct OrangeTheme: AppTheme {
    //FFEEDA
    var baseColor: UIColor { UIColor(red: 1.00, green: 0.93, blue: 0.85, alpha: 1.00) }
    //FFCB8E
    var accentColor: UIColor { UIColor(red: 1.00, green: 0.80, blue: 0.56, alpha: 1.00) }
    
    var incomeTextColor: UIColor { UIColor(red: 0.18, green: 0.55, blue: 0.37, alpha: 1.00) }
    
    var expenseTextColor: UIColor { UIColor(red: 0.76, green: 0.24, blue: 0.27, alpha: 1.00) }
    
}

//MARK: - Yellow
struct YellowTheme: AppTheme {
    //FFF8DD
    var baseColor: UIColor { UIColor(red: 1.00, green: 0.97, blue: 0.87, alpha: 1.00) }
    //FFE38A
    var accentColor: UIColor { UIColor(red: 1.00, green: 0.89, blue: 0.54, alpha: 1.00) }
    
    var incomeTextColor: UIColor { UIColor(red: 0.17, green: 0.48, blue: 0.28, alpha: 1.00) }
    
    var expenseTextColor: UIColor { UIColor(red: 0.77, green: 0.19, blue: 0.19, alpha: 1.00) }
    
}

//MARK: - Green
struct GreenTheme: AppTheme {
    //E9FFEB
    var baseColor: UIColor { UIColor(red: 0.91, green: 1.00, blue: 0.92, alpha: 1.00) }
    //AEEBC4
    var accentColor: UIColor { UIColor(red: 0.68, green: 0.92, blue: 0.77, alpha: 1.00) }
    
    var incomeTextColor: UIColor { UIColor(red: 0.12, green: 0.44, blue: 0.47, alpha: 1.00) }
    
    var expenseTextColor: UIColor { UIColor(red: 0.71, green: 0.23, blue: 0.23, alpha: 1.00) }
    
}

//MARK: - Blue
struct BlueTheme: AppTheme {
    //EBF4FF
    var baseColor: UIColor { UIColor(red: 0.92, green: 0.96, blue: 1.00, alpha: 1.00) }
    //A8CCF2
    var accentColor: UIColor { UIColor(red: 0.66, green: 0.80, blue: 0.95, alpha: 1.00) }
    
    var incomeTextColor: UIColor { UIColor(red: 0.15, green: 0.60, blue: 0.42, alpha: 1.00) }
    
    var expenseTextColor: UIColor { UIColor(red: 0.66, green: 0.20, blue: 0.28, alpha: 1.00) }
    
}

//MARK: - Purple
struct PurpleTheme: AppTheme {
    //F4EBFF
    var baseColor: UIColor { UIColor(red: 0.96, green: 0.92, blue: 1.00, alpha: 1.00) }
    //C6A8F0
    var accentColor: UIColor { UIColor(red: 0.78, green: 0.66, blue: 0.94, alpha: 1.00) }
    
    var incomeTextColor: UIColor { UIColor(red: 0.19, green: 0.56, blue: 0.48, alpha: 1.00) }
    
    var expenseTextColor: UIColor { UIColor(red: 0.76, green: 0.25, blue: 0.42, alpha: 1.00) }
    
}

struct GrayTheme: AppTheme {
    //EFEFEF
    var baseColor: UIColor { UIColor(red: 0.94, green: 0.94, blue: 0.94, alpha: 1.00) }
    //979797
    var accentColor: UIColor { UIColor(red: 0.59, green: 0.59, blue: 0.59, alpha: 1.00) }
    
    var incomeTextColor: UIColor { UIColor(red: 0.00, green: 0.41, blue: 0.36, alpha: 1.00) }
    
    var expenseTextColor: UIColor { UIColor(red: 0.55, green: 0.10, blue: 0.23, alpha: 1.00) }
    
}
