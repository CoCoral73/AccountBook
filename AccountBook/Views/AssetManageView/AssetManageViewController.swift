//
//  AssetManageViewController.swift
//  AccountBook
//
//  Created by 김정원 on 11/5/25.
//

import UIKit

class AssetManageViewController: UIViewController {

    @IBOutlet weak var assetTotalAmountLabel: UILabel!
    @IBOutlet weak var tableView: IntrinsicTableView!
    
    var viewModel: AssetManageViewModel!
    var tableViewHandler: AssetManageTableViewHandler!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        configureTableView()
    }
    
    func configureTableView() {
        tableViewHandler = AssetManageTableViewHandler(viewModel: viewModel)
        tableView.dataSource = tableViewHandler
        tableView.delegate = tableViewHandler
        tableView.sectionHeaderTopPadding = 15
        
        let headerNib = UINib(nibName: "AssetManageTableHeaderView", bundle: nil)
        tableView.register(headerNib, forHeaderFooterViewReuseIdentifier: "AssetManageTableHeaderView")
    }

    @IBAction func infoButtonTapped(_ sender: UIButton) {
    }
    
}
