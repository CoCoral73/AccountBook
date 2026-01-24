//
//  SettingTableViewController.swift
//  AccountBook
//
//  Created by 김정원 on 11/12/25.
//

import UIKit

enum SettingOption {
    case incomeCategory, expenseCategory, transferCategory
    case theme, lockApp
    case rating, help, contact
    
    init(indexPath: IndexPath) {
        switch (indexPath.section, indexPath.row) {
        case (0, 0):
            self = .incomeCategory
        case (0, 1):
            self = .expenseCategory
        case (0, 2):
            self = .transferCategory
        case (1, 0):
            self = .theme
        case (1, 1):
            self = .lockApp
        case (2, 0):
            self = .rating
        case (2, 1):
            self = .help
        default: //(2, 2)
            self = .contact
        }
    }
}

class SettingTableViewController: UITableViewController, ThemeApplicable {
    override func viewDidLoad() {
        super.viewDidLoad()
        
        startObservingTheme()
        applyTheme(ThemeManager.shared.currentTheme)
        
        tableView.sectionHeaderTopPadding = 0
    }
    
    func applyTheme(_ theme: any AppTheme) {
        tableView.backgroundColor = theme.baseColor
    }
    
    deinit {
        stopObservingTheme()
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let option = SettingOption(indexPath: indexPath)
        
        switch option {
        case .incomeCategory:
            showCategoryListView(.income)
        case .expenseCategory:
            showCategoryListView(.expense)
        case .transferCategory:
            showCategoryListView(.transfer)
        case .theme:
            showThemeView()
        case .lockApp:
            showLockAppView()
        case .help:
            showHelpView()
        case .contact:
            showContactView()
        case .rating:
            showRatingView()
        }
        
        tableView.deselectRow(at: indexPath, animated: false)
    }
    
    func showCategoryListView(_ type: TransactionType) {
        let vm = CategoryListViewModel(type: type)
        guard let vc = storyboard?.instantiateViewController(identifier: "CategoryListViewController", creator: { coder in
            CategoryListViewController(coder: coder, viewModel: vm)
        }) else {
            print("SettingTableViewController: VC 생성 오류")
            return
        }
        
        navigationController?.pushViewController(vc, animated: true)
    }
    
    func showThemeView() {
        guard let vc = storyboard?.instantiateViewController(withIdentifier: "ThemeViewController") as? ThemeViewController else {
            print("SettingTableViewController: 테마 VC 생성 오류")
            return
        }
        
        navigationController?.pushViewController(vc, animated: true)
    }
    
    func showLockAppView() {
        guard let vc = storyboard?.instantiateViewController(withIdentifier: "LockAppViewController") as? LockAppViewController else {
            print("SettingTableViewController: 앱 잠금 VC 생성 오류")
            return
        }
        
        navigationController?.pushViewController(vc, animated: true)
    }
    
    func showHelpView() {
        guard let vc = storyboard?.instantiateViewController(withIdentifier: "HelpViewController") as? HelpViewController else {
            print("SettingTableViewController: 도움말 VC 생성 오류")
            return
        }
        
        navigationController?.pushViewController(vc, animated: true)
    }
    
    func showContactView() {
        showMailComposer()
    }
    
    func showRatingView() {
//        let appID = "1234567890" // 너의 앱 ID
//        let urlString = "https://apps.apple.com/app/id\(appID)?action=write-review"
//        if let url = URL(string: urlString) {
//            UIApplication.shared.open(url, options: [:], completionHandler: nil)
//        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.isHidden = false
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.navigationBar.isHidden = true
    }
}
