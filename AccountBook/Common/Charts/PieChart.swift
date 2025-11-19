//
//  PieChart.swift
//  AccountBook
//
//  Created by 김정원 on 10/14/25.
//

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
