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

}
