//
//  AssetManageViewController.swift
//  AccountBook
//
//  Created by 김정원 on 11/5/25.
//

import UIKit

class AssetManageViewController: UIViewController {

    @IBOutlet weak var infoView: UIView!
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
    
    func reloadData() {
        assetTotalAmountLabel.text = viewModel.assetTotalAmountString
        tableView.reloadData()
    }

    @IBAction func infoButtonTapped(_ sender: UIButton) {
        infoView.isHidden = false
    }
    @IBAction func closeInfoButtonTapped(_ sender: UIButton) {
        infoView.isHidden = true
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        reloadData()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        infoView.layer.shadowColor = UIColor.black.cgColor
        infoView.layer.shadowOpacity = 0.2
        infoView.layer.shadowOffset = CGSize(width: 1, height: 1)
        infoView.layer.shadowRadius = 2
    }
}
