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
    
    override func viewDidLoad() {
        super.viewDidLoad()

        
    }

    @IBAction func infoButtonTapped(_ sender: UIButton) {
    }
    
}
