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
        configureTabBar()
        injectViewModel()
        
        applyTheme(ThemeManager.shared.currentTheme)
    }
    
    func applyTheme(_ theme: any AppTheme) {
        tabBar.standardAppearance.backgroundColor = theme.baseColor
        tabBar.scrollEdgeAppearance?.backgroundColor = theme.baseColor
    }
    
    private func configureTabBar() {
        let appearance = UITabBarAppearance()
        appearance.configureWithDefaultBackground()
        appearance.stackedLayoutAppearance.selected.iconColor = .darkGray
        appearance.stackedLayoutAppearance.selected.titleTextAttributes = [.foregroundColor: UIColor.darkGray]
        tabBar.standardAppearance = appearance
        tabBar.scrollEdgeAppearance = appearance
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
    
    deinit {
        stopObservingTheme()
    }
}
