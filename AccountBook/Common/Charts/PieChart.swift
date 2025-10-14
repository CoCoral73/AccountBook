//
//  PieChart.swift
//  AccountBook
//
//  Created by 김정원 on 10/14/25.
//

import UIKit
import DGCharts

final class PercentValueFormatter: ValueFormatter {
    private let fmt = NumberFormatter()

    init(fractionDigits: Int = 1) {
        fmt.numberStyle = .decimal
        fmt.minimumFractionDigits = fractionDigits
        fmt.maximumFractionDigits = fractionDigits
        fmt.roundingMode = .halfUp
    }

    func stringForValue(_ value: Double, entry: ChartDataEntry, dataSetIndex: Int, viewPortHandler: ViewPortHandler?) -> String {
        return (fmt.string(from: NSNumber(value: value)) ?? "0") + "%"
    }
}

let chartColors: [UIColor] = [
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
