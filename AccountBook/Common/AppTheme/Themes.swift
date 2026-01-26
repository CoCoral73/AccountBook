//
//  PinkTheme.swift
//  AccountBook
//
//  Created by 김정원 on 11/17/25.
//
import UIKit

//MARK: - Pink
struct PinkTheme: AppTheme {
    //FFF0F0
    var baseColor: UIColor { UIColor(red: 1.00, green: 0.94, blue: 0.94, alpha: 1.00) }
    //FF8F8F
    var accentColor: UIColor { UIColor(red: 1.00, green: 0.56, blue: 0.56, alpha: 1.00) }
}

//MARK: - Orange
struct OrangeTheme: AppTheme {
    //FFF6E6
    var baseColor: UIColor { UIColor(red: 1.00, green: 0.96, blue: 0.90, alpha: 1.00) }
    //FFB940
    var accentColor: UIColor { UIColor(red: 1.00, green: 0.73, blue: 0.25, alpha: 1.00) }
}

//MARK: - Yellow
struct YellowTheme: AppTheme {
    //FFFAE4
    var baseColor: UIColor { UIColor(red: 1.00, green: 0.98, blue: 0.89, alpha: 1.00) }
    //FFD900
    var accentColor: UIColor { UIColor(red: 1.00, green: 0.85, blue: 0.00, alpha: 1.00) }
}

//MARK: - Green
struct GreenTheme: AppTheme {
    //EFFFEB
    var baseColor: UIColor { UIColor(red: 0.94, green: 1.00, blue: 0.92, alpha: 1.00) }
    //A4E298
    var accentColor: UIColor { UIColor(red: 0.64, green: 0.89, blue: 0.60, alpha: 1.00) }
}

//MARK: - Blue
struct BlueTheme: AppTheme {
    //F1F8FF
    var baseColor: UIColor { UIColor(red: 0.95, green: 0.97, blue: 1.00, alpha: 1.00) }
    //80B2E6
    var accentColor: UIColor { UIColor(red: 0.50, green: 0.70, blue: 0.90, alpha: 1.00) }
}

//MARK: - Purple
struct PurpleTheme: AppTheme {
    //F9F5FF
    var baseColor: UIColor { UIColor(red: 0.98, green: 0.96, blue: 1.00, alpha: 1.00) }
    //BD99F0
    var accentColor: UIColor { UIColor(red: 0.74, green: 0.60, blue: 0.94, alpha: 1.00) }
}

struct GrayTheme: AppTheme {
    //F7F7F7
    var baseColor: UIColor { UIColor(red: 0.97, green: 0.97, blue: 0.97, alpha: 1.00) }
    //878787
    var accentColor: UIColor { UIColor(red: 0.53, green: 0.53, blue: 0.53, alpha: 1.00)}
}
