//
//  SettingTableViewController.swift
//  AccountBook
//
//  Created by 김정원 on 11/12/25.
//

import UIKit

enum SettingOption {
    case incomeCategory, expenseCategory
    case theme, lockApp
    case help, contact, rating
    
    init(indexPath: IndexPath) {
        switch (indexPath.section, indexPath.row) {
        case (0, 0):
            self = .incomeCategory
        case (0, 1):
            self = .expenseCategory
        case (1, 0):
            self = .theme
        case (1, 1):
            self = .lockApp
        case (2, 0):
            self = .help
        case (2, 1):
            self = .contact
        default: //(2, 2)
            self = .rating
        }
    }
}

class SettingTableViewController: UITableViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let option = SettingOption(indexPath: indexPath)
        
        switch option {
        case .incomeCategory:
            showCategoryListView(true)
        case .expenseCategory:
            showCategoryListView(false)
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
    }
    
    func showCategoryListView(_ isIncome: Bool) {
        let vm = CategoryListViewModel(isIncome: isIncome)
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
        
    }
    
    func showContactView() {
        
    }
    
    func showRatingView() {
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.isHidden = true
    }
}
