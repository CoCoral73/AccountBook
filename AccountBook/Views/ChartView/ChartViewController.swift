//
//  ChartViewController.swift
//  AccountBook
//
//  Created by 김정원 on 9/19/25.
//

import UIKit
import DGCharts

class ChartViewController: UIViewController {

    @IBOutlet weak var cancelButton: UIBarButtonItem!
    @IBOutlet weak var periodButton: UIBarButtonItem!
    @IBOutlet weak var applyButton: UIBarButtonItem!
    
    @IBOutlet weak var pieChartView: PieChartView!
    @IBOutlet weak var tableViewByCategory: UITableView!
    @IBOutlet weak var tableViewByCategoryHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var tableViewByAsset: UITableView!
    @IBOutlet weak var tableViewByAssetHeightConstraint: NSLayoutConstraint!
    
    var viewModel: ChartViewModel!
    var tableByCategoryHandler: TableByCategoryHandler!
    var tableByAssetHandler: TableByAssetHandler!
    
    private var setPeriodMode: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()

        configurePieChartView()
        configureTableView()
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
    
    func reloadData() {
        viewModel.reloadTxs()
        pieChartView.data = viewModel.chartData
        pieChartView.notifyDataSetChanged()
        
        tableViewByCategory.reloadData()
        tableViewByAsset.reloadData()
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
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        DispatchQueue.main.async {
           self.reloadData()
       }
    }
    
    @IBAction func periodButtonTapped(_ sender: UIBarButtonItem) {
        setPeriodMode.toggle()
        
        cancelButton.isHidden = !setPeriodMode
        applyButton.isHidden = !setPeriodMode
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        tableViewByCategoryHeightConstraint.constant = tableViewByCategory.contentSize.height
        tableViewByAssetHeightConstraint.constant = tableViewByAsset.contentSize.height
    }
    
}
