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
        pieChartView.drawEntryLabelsEnabled = true
        pieChartView.drawHoleEnabled = false
        pieChartView.holeRadiusPercent = 0
        pieChartView.transparentCircleRadiusPercent = 0
        pieChartView.legend.enabled = false
        
        //여백 설정, 안하면 그래프 이미지 비율이 커짐
        pieChartView.setExtraOffsets(left: 0, top: 20, right: 0, bottom: 0)
        pieChartView.minOffset = 10
    }
    
    func configureChartData() {
        pieChartView.data = viewModel.chartData
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // ViewModel에서 최신 데이터 반영
        pieChartView.data = viewModel.chartData
        // 차트 갱신
        pieChartView.notifyDataSetChanged()
    }
    
    @IBAction func periodButtonTapped(_ sender: UIBarButtonItem) {
    }
    
}
