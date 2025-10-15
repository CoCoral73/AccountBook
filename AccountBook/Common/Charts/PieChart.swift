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
    private let total: Double

    init(entries: [PieChartDataEntry], fractionDigits: Int = 1) {
        total = entries.reduce(0) { $0 + $1.value }
        
        fmt.numberStyle = .decimal
        fmt.minimumFractionDigits = fractionDigits
        fmt.maximumFractionDigits = fractionDigits
        fmt.roundingMode = .halfUp
    }

    func stringForValue(_ value: Double, entry: ChartDataEntry, dataSetIndex: Int, viewPortHandler: ViewPortHandler?) -> String {
        guard let pieEntry = entry as? PieChartDataEntry else { return "" }
            
        let ratio = pieEntry.value / total
            
        // 전체의 3% 미만이면 내부에 표시 안함 (빈 문자열)
        if ratio < 0.03 {
            return ""
        }
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
