//
//  ChartViewModel.swift
//  AccountBook
//
//  Created by 김정원 on 9/19/25.
//

import UIKit
import DGCharts

enum StatisticPeriod {
    case monthly, yearly, custom
}

class ChartViewModel {
    
    var period: StatisticPeriod = .monthly
    var startDate: Date  //월별, 연간
    var endDate: Date?  //커스텀
    
    init(_ date: Date = Date()) {
        startDate = date
    }
    
    func setChartData() -> PieChartData {
        let categoryData: [(category: String, amount: Double)] = [
            ("식비", 300.0),
            ("교통", 150.0),
            ("취미", 200.0),
            ("쇼핑", 100.0)
        ]

        let entries = categoryData.map { PieChartDataEntry(value: $0.amount, label: $0.category) }
        
        //label: 각 데이터의 레이블 표시
        let dataSet = PieChartDataSet(entries: entries, label: "테스트")

        // 색상 팔레트
        dataSet.colors = ChartColorTemplates.material() + ChartColorTemplates.pastel()

        // 레이블을 섹션 바깥으로 빼고 선 연결
        dataSet.xValuePosition = .outsideSlice
        dataSet.yValuePosition = .outsideSlice
        dataSet.valueLinePart1OffsetPercentage = 0.8
        dataSet.valueLinePart1Length = 0.3
        dataSet.valueLinePart2Length = 0.4
        dataSet.valueLineWidth = 1.0
        dataSet.valueLineColor = .darkGray

        let data = PieChartData(dataSet: dataSet)
        let formatter = NumberFormatter()
        formatter.numberStyle = .percent
        formatter.maximumFractionDigits = 1
        data.setValueFormatter(DefaultValueFormatter(formatter: formatter))
        data.setValueFont(.systemFont(ofSize: 14, weight: .bold))
        data.setValueTextColor(.black)

        return data
        
    }
}
