//
//  ChartViewController.swift
//  AccountBook
//
//  Created by 김정원 on 9/19/25.
//

import UIKit
import DGCharts

class ChartViewController: UIViewController {

    @IBOutlet weak var periodButton: UIButton!
    @IBOutlet weak var modeButton: UIButton!
    
    @IBOutlet weak var totalTitleLabel: UILabel!
    @IBOutlet weak var totalAmountLabel: UILabel!
    @IBOutlet weak var categoryTitleLabel: UILabel!
    @IBOutlet weak var assetTitleLabel: UILabel!
    
    @IBOutlet weak var pieChartView: PieChartView!
    @IBOutlet weak var tableViewByCategory: IntrinsicTableView!
    @IBOutlet weak var tableViewByAsset: IntrinsicTableView!
    
    @IBOutlet weak var barChartStackView: UIStackView!
    @IBOutlet weak var barChartView: BarChartView!
    
    var viewModel: ChartViewModel!
    var tableByCategoryHandler: TableByCategoryHandler!
    var tableByAssetHandler: TableByAssetHandler!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        bindViewModel()
        configureUI()
        configurePieChartView()
        configureTableView()
        configureBarChartView()
    }
    
    func bindViewModel() {
        viewModel.onDidSetPeriod = { [weak self] in
            guard let self = self else { return }
            DispatchQueue.main.async {
                self.periodButton.setTitle(self.viewModel.periodDisplay, for: .normal)
                self.barChartStackView.isHidden = self.viewModel.isBarChartHidden
                self.barChartView.isHidden = self.viewModel.isBarChartHidden
                self.reloadData()
            }
        }
        
        viewModel.onDidSetIsIncome = { [weak self] in
            guard let self = self else { return }
            DispatchQueue.main.async {
                self.modeButton.setTitle(self.viewModel.modeTitle, for: .normal)
                self.totalTitleLabel.text = self.viewModel.totalTitle
                self.categoryTitleLabel.text = self.viewModel.categoryTitle
                self.assetTitleLabel.text = self.viewModel.assetTitle
                self.reloadData(shouldReloadTxs: false)
            }
        }
        
        viewModel.onPresentPeriodSelectionVC = { [weak self] vm in
            guard let self = self else { return }
            guard let periodVC = self.storyboard?.instantiateViewController(identifier: "PeriodSelectionViewController", creator: { coder in
                PeriodSelectionViewController(coder: coder, viewModel: vm)
            }) else {
                fatalError("PeriodSelectionViewController 생성 에러")
            }

            if let sheet = periodVC.sheetPresentationController {
                sheet.detents = [.custom { _ in
                    return periodVC.preferredContentSize.height
                }]
                sheet.prefersGrabberVisible = true
            }

            DispatchQueue.main.async {
                self.present(periodVC, animated: true, completion: nil)
            }
        }
    }
    
    func configureUI() {
        periodButton.setTitle(viewModel.periodDisplay, for: .normal)
        modeButton.setTitle(viewModel.modeTitle, for: .normal)
        modeButton.backgroundColor = viewModel.isIncome ? ThemeManager.shared.currentTheme.incomeColor : ThemeManager.shared.currentTheme.expenseColor
        totalTitleLabel.text = viewModel.totalTitle
        totalAmountLabel.text = viewModel.totalAmountDisplay
        categoryTitleLabel.text = viewModel.categoryTitle
        assetTitleLabel.text = viewModel.assetTitle
        barChartStackView.isHidden = viewModel.isBarChartHidden
        barChartView.isHidden = viewModel.isBarChartHidden
    }
    
    func configurePieChartView() {
        pieChartView.usePercentValuesEnabled = true
        pieChartView.drawEntryLabelsEnabled = true
        pieChartView.drawHoleEnabled = false
        pieChartView.transparentCircleRadiusPercent = 0
        pieChartView.legend.enabled = false
        pieChartView.highlightPerTapEnabled = false
        pieChartView.rotationEnabled = false
        pieChartView.setExtraOffsets(left: 0, top: 20, right: 0, bottom: 0)
        pieChartView.minOffset = 10
    }
    
    func configureTableView() {
        tableByCategoryHandler = TableByCategoryHandler(viewModel: viewModel)
        tableViewByCategory.dataSource = tableByCategoryHandler
        tableViewByCategory.delegate = tableByCategoryHandler
        
        tableByAssetHandler = TableByAssetHandler(viewModel: viewModel)
        tableViewByAsset.dataSource = tableByAssetHandler
        tableViewByAsset.delegate = tableByAssetHandler
        tableViewByAsset.sectionHeaderTopPadding = 0
        
        let headerNib = UINib(nibName: "AssetSectionHeaderView", bundle: nil)
        tableViewByAsset.register(headerNib, forHeaderFooterViewReuseIdentifier: "AssetSectionHeaderView")
    }
    
    func configureBarChartView() {
        barChartView.legend.enabled = false     //범례 표시
        barChartView.leftAxis.enabled = false   //좌측 y축 표시
        barChartView.rightAxis.enabled = false  //우측 y축 표시
        barChartView.leftAxis.axisMinimum = 0
        barChartView.xAxis.labelPosition = .bottom
        barChartView.xAxis.drawGridLinesEnabled = false     //true: 바 중심축 생김
        barChartView.xAxis.labelTextColor = .secondaryLabel
        barChartView.xAxis.axisLineColor = .clear
        barChartView.highlightPerTapEnabled = false
        barChartView.setExtraOffsets(left: 20, top: 0, right: 20, bottom: 0)
    }
    
    private func makeChartDataForPieChart() -> PieChartData {
        let data = viewModel.totalByCategory
        
        if data.isEmpty {
            let entry = PieChartDataEntry(value: 1.0, label: "")
            let dataSet = PieChartDataSet(entries: [entry])
            
            dataSet.colors = [.lightGray.withAlphaComponent(0.3)]
            dataSet.drawValuesEnabled = false   // 퍼센트 값 숨김
            
            let chartData = PieChartData(dataSet: dataSet)
            viewModel.setViewModelsForTableView(with: [])  // 테이블뷰 데이터도 비움
            return chartData
        }
        
        let sorted = data.sorted(by: { $0.value > $1.value })   //내림차순 정렬
        let entries = sorted.map { PieChartDataEntry(value: Double($0.value), label: $0.key.name) }
        
        //label: 각 데이터의 레이블 표시
        let dataSet = PieChartDataSet(entries: entries)

        // 색상 팔레트
        var colors = ThemeManager.shared.currentTheme.chartColors
        if entries.count > colors.count {
            colors.append(contentsOf: Array(repeating: colors.last!, count: entries.count - colors.count))
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

        viewModel.setViewModelsForTableView(with: sorted.map { TableByCategoryCellViewModel(category: $0.key, amount: Double($0.value), total: chartData.yValueSum)})
        tableByCategoryHandler.chartColors = colors
        
        return chartData
        
    }
    
    private func makeChartDataForBarChart() -> (data: BarChartData, label: [String]) {
        let data = viewModel.loadTotalsFor6Months()
        let entries = data.enumerated().map { BarChartDataEntry(x: Double($0.offset), y: Double($0.element.1)) }
        let dataSet = BarChartDataSet(entries: entries)
        dataSet.colors = [ThemeManager.shared.currentTheme.accentColor]
        
        let chartData = BarChartData(dataSet: dataSet)
        return (chartData, data.map { $0.0 })
    }
    
    func reloadData(shouldReloadTxs: Bool = true) {
        if shouldReloadTxs {
            viewModel.reloadTxs()
        }
        
        totalAmountLabel.text = viewModel.totalAmountDisplay
        
        pieChartView.data = makeChartDataForPieChart()
        pieChartView.centerText = viewModel.chartCenterText
        pieChartView.notifyDataSetChanged()
        
        let chartData = makeChartDataForBarChart()
        barChartView.data = chartData.data
        barChartView.xAxis.valueFormatter = IndexAxisValueFormatter(values: chartData.label)
        barChartView.notifyDataSetChanged()
        
        tableViewByCategory.reloadData()
        tableViewByAsset.reloadData()
    }
    
    @IBAction func periodButtonTapped(_ sender: UIButton) {
        viewModel.handlePeriodButton()
    }
    
    @IBAction func modeButtonTapped(_ sender: UIButton) {
        viewModel.handleModeButton()
        modeButton.backgroundColor = viewModel.isIncome ? ThemeManager.shared.currentTheme.incomeColor : ThemeManager.shared.currentTheme.expenseColor
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        reloadData()
    }
    
}
