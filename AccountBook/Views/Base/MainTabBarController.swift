//
//  MainTabBarController.swift
//  AccountBook
//
//  Created by 김정원 on 10/13/25.
//

import UIKit

class MainTabBarController: UITabBarController {
    private let calendarViewModel = CalendarViewModel()
    private let chartViewModel = ChartViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        injectViewModel()
    }
    
    private func injectViewModel() {
        if let mainNav = viewControllers?[0] as? UINavigationController,
           let calendarVC = mainNav.topViewController as? CalendarViewController {
            calendarVC.viewModel = calendarViewModel
        }
        
        if let chartVC = viewControllers?[1] as? ChartViewController {
            chartVC.viewModel = chartViewModel
        }
    }
}
