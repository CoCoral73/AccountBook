//
//  ChartViewController.swift
//  AccountBook
//
//  Created by 김정원 on 9/19/25.
//

import UIKit
import DGCharts

class ChartViewController: UIViewController {

    @IBOutlet weak var periodButton: UIBarButtonItem!
    
    @IBOutlet weak var totalTitleLabel: UILabel!
    @IBOutlet weak var totalAmountLabel: UILabel!
    @IBOutlet weak var categoryTitleLabel: UILabel!
    @IBOutlet weak var assetTitleLabel: UILabel!
    
    @IBOutlet weak var pieChartView: PieChartView!
    @IBOutlet weak var tableViewByCategory: UITableView!
    @IBOutlet weak var tableViewByCategoryHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var tableViewByAsset: UITableView!
    @IBOutlet weak var tableViewByAssetHeightConstraint: NSLayoutConstraint!
    
    var viewModel: ChartViewModel!
    var tableByCategoryHandler: TableByCategoryHandler!
    var tableByAssetHandler: TableByAssetHandler!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        configureUI()
        configurePieChartView()
        configureTableView()
    }
    
    func configureUI() {
        periodButton.title = viewModel.periodButtonTitleString
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
        
        pieChartView.data = viewModel.chartData
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
    
    func reloadData() {
        viewModel.reloadTxs()
        pieChartView.data = viewModel.chartData
        pieChartView.notifyDataSetChanged()
        
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            tableViewByCategory.reloadData()
            tableViewByAsset.reloadData()
            
            tableViewByCategory.layoutIfNeeded()
            tableViewByAsset.layoutIfNeeded()
            
            tableViewByCategoryHeightConstraint.constant = tableViewByCategory.contentSize.height
            tableViewByAssetHeightConstraint.constant = tableViewByAsset.contentSize.height
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        reloadData()
    }
    
    @IBAction func periodButtonTapped(_ sender: UIBarButtonItem) {
        viewModel.handlePeriodButton(storyboard: storyboard, fromVC: self)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        let categoryContentHeight = tableViewByCategory.contentSize.height
        if tableViewByCategoryHeightConstraint.constant != categoryContentHeight {
            tableViewByCategoryHeightConstraint.constant = categoryContentHeight
        }

        let assetContentHeight = tableViewByAsset.contentSize.height
        if tableViewByAssetHeightConstraint.constant != assetContentHeight {
            tableViewByAssetHeightConstraint.constant = assetContentHeight
        }
    }
    
}
