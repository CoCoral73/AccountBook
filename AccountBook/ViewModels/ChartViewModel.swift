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
    
    private var periodType: StatisticPeriod = .monthly { didSet { loadTransactions() } }
    private var startDate: Date, endDate: Date
    var isIncome: Bool = false
    
    private var txs: [Transaction] = []
    private var incomeData: [Category: Int64] = [:]
    private var expenseData: [Category: Int64] = [:]
    
    init(_ date: Date = Date()) {
        startDate = date
        endDate = date
        
        loadTransactions()
    }
    
    var chartData: PieChartData { makeChartData() }
    
    func setPeriod(_ periodType: StatisticPeriod, _ date: Date, _ endDate: Date = Date()) {
        self.startDate = date
        self.endDate = endDate
        self.periodType = periodType
    }
    
    func aggregateAmountByCategory() {
        incomeData.removeAll()
        expenseData.removeAll()
        
        for tx in txs {
            if tx.isIncome {
                incomeData[tx.category, default: 0] += tx.amount
            } else {
                expenseData[tx.category, default: 0] += tx.amount
            }
        }
    }
    
    func loadTransactions() {
        switch periodType {
        case .monthly:
            txs = CoreDataManager.shared.fetchTransactions(forMonth: startDate)
        case .yearly:
            txs = CoreDataManager.shared.fetchTransactions(forYear: startDate)
        case .custom:
            txs = CoreDataManager.shared.fetchTransactions(startDate: startDate, endDate: endDate)
        }
        
        aggregateAmountByCategory()
    }

    func makeChartData() -> PieChartData {
        let data = isIncome ? incomeData : expenseData
        let sorted = data.sorted(by: { $0.value > $1.value })   //내림차순 정렬
        let entries = sorted.map { PieChartDataEntry(value: Double($0.value), label: $0.key.name) }
        
        //label: 각 데이터의 레이블 표시
        let dataSet = PieChartDataSet(entries: entries)

        // 색상 팔레트
        dataSet.colors = chartColors

        // 레이블을 섹션 바깥으로 빼고 선 연결
        // 값은 섹션 안쪽에 표시, 레이블만 연결선으로 표시
        dataSet.xValuePosition = .outsideSlice
        dataSet.yValuePosition = .insideSlice
        dataSet.valueLinePart1OffsetPercentage = 1.0
        dataSet.valueLinePart1Length = 0.8
        dataSet.valueLinePart2Length = 0.3
        dataSet.valueLineWidth = 1.0
        dataSet.valueLineColor = .darkGray

        let chartData = PieChartData(dataSet: dataSet)
        chartData.setValueFormatter(PercentValueFormatter())
        chartData.setValueFont(.systemFont(ofSize: 14, weight: .bold))
        chartData.setValueTextColor(.black)

        return chartData
        
    }
}
