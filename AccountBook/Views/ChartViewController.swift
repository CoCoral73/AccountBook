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
    
    var viewModel: ChartViewModel!
    
    private var setPeriodMode: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()

        configurePieChartView()
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
    
    func reloadCharts() {
        viewModel.reloadChart()
        pieChartView.data = viewModel.chartData
        pieChartView.notifyDataSetChanged()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        reloadCharts()
    }
    
    @IBAction func periodButtonTapped(_ sender: UIBarButtonItem) {
        setPeriodMode.toggle()
        
        cancelButton.isHidden = !setPeriodMode
        applyButton.isHidden = !setPeriodMode
    }
    
}
