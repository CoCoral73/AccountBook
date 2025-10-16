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
    
    var viewModel: ChartViewModel!
    
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
        viewModel.reloadChart()
        pieChartView.data = viewModel.chartData
        pieChartView.notifyDataSetChanged()
        
        tableViewByCategory.reloadData()
    }
    
    func configureTableView() {
        tableViewByCategory.dataSource = self
        tableViewByCategory.delegate = self
        
        tableViewByCategory.rowHeight = 55
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        reloadData()
    }
    
    @IBAction func periodButtonTapped(_ sender: UIBarButtonItem) {
        setPeriodMode.toggle()
        
        cancelButton.isHidden = !setPeriodMode
        applyButton.isHidden = !setPeriodMode
    }
    
}

extension ChartViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        viewModel.tableViewViewModels.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableViewByCategory.dequeueReusableCell(withIdentifier: Cell.categoryChartCell, for: indexPath) as! ChartByCategoryTableViewCell
        let vm = viewModel.tableViewViewModels[indexPath.row]
        
        cell.viewModel = vm
        
        return cell
    }
    
}
