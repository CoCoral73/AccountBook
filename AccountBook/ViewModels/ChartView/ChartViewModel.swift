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

struct AssetSection {
    let assetType: AssetType       // 섹션 제목: 자산 종류 (예: 신용카드)
    let totalAmount: Int64         // 섹션 전체 금액 합계
    let rows: [AssetRow]           // 섹션에 포함될 자산별 내역
}

struct AssetRow {
    let asset: AssetItem               // 세부 자산 (예: 삼성카드)
    let amount: Int64              // 해당 자산의 총 금액
}

class ChartViewModel {
    
    private var periodType: StatisticPeriod = .monthly { didSet { loadTransactions() } }
    private var startDate: Date, endDate: Date
    var isIncome: Bool = false
    
    private var txs: [Transaction] = [] { didSet { calculateTotals() } }
    private var totalByCategory: [Category: Int64] = [:]
    private var sectionsByAsset: [AssetSection] = []
    
    init(_ date: Date = Date()) {
        startDate = date
        endDate = date
        
        loadTransactions()
    }
    
    var chartData: PieChartData { makeChartData() }
    var byCategoryViewModels: [TableByCategoryCellViewModel] = []
    
    var numberOfSectionsByAsset: Int {
        sectionsByAsset.count
    }
    func numberOfRowsInSectionByAsset(section: Int) -> Int {
        sectionsByAsset[section].rows.count
    }
    func cellForRowAtByAsset(indexPath: IndexPath) -> (name: String, amount: String) {
        let (section, row) = (indexPath.section, indexPath.row)
        let data = sectionsByAsset[section].rows[row]
        return (data.asset.name, data.amount.formattedWithComma)
    }
    func viewForHeaderInSectionByAsset(section: Int) -> (name: String, amount: String) {
        let data = sectionsByAsset[section]
        return (data.assetType.displayName, data.totalAmount.formattedWithComma)
    }
    
    func reloadTxs() {
        loadTransactions()
    }
    
    func setPeriod(_ periodType: StatisticPeriod, _ date: Date, _ endDate: Date = Date()) {
        self.startDate = date
        self.endDate = endDate
        self.periodType = periodType
    }
    
    private func calculateTotals() {    //수입, 지출 모드 바뀔 때 호출
        totalByCategory.removeAll()
        var totalByAsset: [AssetItem: Int64] = [:]
        var totalByAssetType: [AssetType: Int64] = [:]
        
        for tx in txs {
            if tx.isIncome == isIncome {
                let category = tx.category
                let asset = tx.asset
                let value = Int(asset.type), type = AssetType(rawValue: value)!
                
                totalByCategory[category, default: 0] += tx.amount
                totalByAsset[asset, default: 0] += tx.amount
                totalByAssetType[type, default: 0] += tx.amount
            }
        }
        
        var sections: [AssetSection] = []

        for type in AssetType.allCases {
            guard let totalAmount = totalByAssetType[type] else { continue }

            // 해당 타입에 속한 자산 필터링
            let filtered = totalByAsset.filter { $0.key.type == type.rawValue }
            let sorted = filtered.sorted(by: { $0.value > $1.value }) // 자산끼리는 금액순 유지

            let rows = type == .cash ? [] : sorted.map { AssetRow(asset: $0.key, amount: $0.value) }
            sections.append(AssetSection(assetType: type, totalAmount: totalAmount, rows: rows))
        }
        
        sectionsByAsset = sections
    }
    
    private func loadTransactions() {
        switch periodType {
        case .monthly:
            txs = CoreDataManager.shared.fetchTransactions(forMonth: startDate)
        case .yearly:
            txs = CoreDataManager.shared.fetchTransactions(forYear: startDate)
        case .custom:
            txs = CoreDataManager.shared.fetchTransactions(startDate: startDate, endDate: endDate)
        }
    }

    private func makeChartData() -> PieChartData {
        let data = totalByCategory
        let sorted = data.sorted(by: { $0.value > $1.value })   //내림차순 정렬
        let entries = sorted.map { PieChartDataEntry(value: Double($0.value), label: $0.key.name) }
        
        //label: 각 데이터의 레이블 표시
        let dataSet = PieChartDataSet(entries: entries)

        // 색상 팔레트
        var colors = chartColors
        if entries.count > colors.count {
            colors.append(contentsOf: Array(repeating: chartColors.last!, count: entries.count - colors.count))
        }
        dataSet.colors = colors

        // 레이블을 섹션 바깥으로 빼고 선 연결
        // 값은 섹션 안쪽에 표시, 레이블만 연결선으로 표시
        dataSet.xValuePosition = .outsideSlice
        dataSet.yValuePosition = .insideSlice
        dataSet.valueLinePart1OffsetPercentage = 1.0
        dataSet.valueLinePart1Length = 0.8
        dataSet.valueLinePart2Length = 0.1
        dataSet.valueLineWidth = 1.0
        dataSet.valueLineColor = .darkGray

        let chartData = PieChartData(dataSet: dataSet)
        chartData.setValueFormatter(PercentValueFormatter(entries: entries))
        chartData.setValueFont(.systemFont(ofSize: 13, weight: .semibold))
        chartData.setValueTextColor(.black)

        byCategoryViewModels = zip(sorted, colors).map { TableByCategoryCellViewModel(category: $0.key, amount: Double($0.value), total: chartData.yValueSum, color: $1)}
        
        return chartData
        
    }
}
