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
    
    var viewModel: ChartViewModel!
    var tableByCategoryHandler: TableByCategoryHandler!
    var tableByAssetHandler: TableByAssetHandler!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        bindViewModel()
        configureUI()
        configurePieChartView()
        configureTableView()
    }
    
    func bindViewModel() {
        viewModel.onDidSetPeriod = { [weak self] in
            guard let self = self else { return }
            periodButton.setTitle(viewModel.periodButtonTitleString, for: .normal)
            reloadData()
        }
        
        viewModel.onDidSetIsIncome = { [weak self] in
            guard let self = self else { return }
            modeButton.setTitle(viewModel.modeButtonString, for: .normal)
            totalTitleLabel.text = viewModel.totalTitleString
            categoryTitleLabel.text = viewModel.categoryTitleString
            assetTitleLabel.text = viewModel.assetTitleString
            reloadData(shouldReloadTxs: false)
        }
    }
    
    func configureUI() {
        periodButton.setTitle(viewModel.periodButtonTitleString, for: .normal)
        modeButton.setTitle(viewModel.modeButtonString, for: .normal)
        totalTitleLabel.text = viewModel.totalTitleString
        totalAmountLabel.text = viewModel.totalAmountString
        categoryTitleLabel.text = viewModel.categoryTitleString
        assetTitleLabel.text = viewModel.assetTitleString
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
        
        pieChartView.data = viewModel.chartDataForPieChart
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
    
    func reloadData(shouldReloadTxs: Bool = true) {
        if shouldReloadTxs {
            viewModel.reloadTxs()
        }
        
        totalAmountLabel.text = viewModel.totalAmountString
        
        pieChartView.data = viewModel.chartDataForPieChart
        pieChartView.centerText = viewModel.chartCenterText
        pieChartView.notifyDataSetChanged()
        
        tableViewByCategory.reloadData()
        tableViewByAsset.reloadData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        reloadData()
    }
    
    @IBAction func periodButtonTapped(_ sender: UIButton) {
        viewModel.handlePeriodButton(storyboard: storyboard, fromVC: self)
    }
    
    @IBAction func modeButtonTapped(_ sender: UIButton) {
        viewModel.handleModeButton()
    }
    
}
