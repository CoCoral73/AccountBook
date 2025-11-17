//
//  MainTabBarController.swift
//  AccountBook
//
//  Created by 김정원 on 10/13/25.
//

import UIKit

class MainTabBarController: UITabBarController, ThemeApplicable {
    private let calendarViewModel = CalendarViewModel()
    private let chartViewModel = ChartViewModel()
    private let assetManageViewModel = AssetManageViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        startObservingTheme()
        injectViewModel()
    }
    
    func applyTheme(_ theme: any AppTheme) {
        tabBar.backgroundColor = theme.baseColor
    }
    
    private func injectViewModel() {
        if let mainNav = viewControllers?[0] as? UINavigationController,
           let calendarVC = mainNav.topViewController as? CalendarViewController {
            calendarVC.viewModel = calendarViewModel
        }
        
        if let chartVC = viewControllers?[1] as? ChartViewController {
            chartVC.viewModel = chartViewModel
        }
        
        if let navVC = viewControllers?[2] as? UINavigationController,
            let assetManageVC = navVC.topViewController as? AssetManageViewController {
            assetManageVC.viewModel = assetManageViewModel
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        applyInitialTheme()
    }
    
    deinit {
        stopObservingTheme()
    }
}
