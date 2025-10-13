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
    @IBOutlet weak var pieChartView: PieChartView!
    
    var viewModel: ChartViewModel!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        configureChartView()
        configureChartData()
    }
    
    func configureChartView() {
        pieChartView.usePercentValuesEnabled = true
        pieChartView.drawEntryLabelsEnabled = false
//        pieChartView.drawHoleEnabled = true
//        pieChartView.holeRadiusPercent = 0
        pieChartView.transparentCircleRadiusPercent = 0.55
        pieChartView.legend.enabled = true
        
        //여백 설정, 안하면 그래프 이미지 비율이 커짐
        pieChartView.setExtraOffsets(left: 24, top: 24, right: 24, bottom: 24)
        pieChartView.minOffset = 10
    }
    
    func configureChartData() {
        pieChartView.data = viewModel.setChartData()
        pieChartView.animate(xAxisDuration: 0.8, yAxisDuration: 0.8, easingOption: .easeOutBack)
    }
    
    @IBAction func periodButtonTapped(_ sender: UIBarButtonItem) {
    }
    
}
