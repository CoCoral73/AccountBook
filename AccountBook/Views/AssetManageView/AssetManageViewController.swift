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
    var tableViewHandler: AssetInfoTableViewHandler!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        bindViewModel()
        configureTableView()
    }
    
    func bindViewModel() {
        viewModel.onPushAssetItemDetail = { [weak self] vm in
            guard let self = self else { return }
            DispatchQueue.main.async {
                self.showAssetItemDetailView(vm)
            }
        }
    }
    
    func configureTableView() {
        tableViewHandler = AssetInfoTableViewHandler(viewModel: viewModel)
        tableView.dataSource = tableViewHandler
        tableView.delegate = tableViewHandler
        tableView.sectionHeaderTopPadding = 15
        
        let headerNib = UINib(nibName: "AssetInfoTableViewHeaderView", bundle: nil)
        tableView.register(headerNib, forHeaderFooterViewReuseIdentifier: "AssetInfoTableViewHeaderView")
    }
    
    func reloadData() {
        assetTotalAmountLabel.text = viewModel.assetTotalAmountString
        tableView.reloadData()
    }
    
    func showAssetItemDetailView(_ vm: AssetItemDetailViewModel) {
        guard let vc = storyboard?.instantiateViewController(identifier: "AssetItemDetailViewController", creator: { coder in
            AssetItemDetailViewController(coder: coder, viewModel: vm)
        }) else {
            print("AssetManageViewController: AssetItem Detail VC 생성 오류")
            return
        }
        
        navigationController?.pushViewController(vc, animated: true)
    }

    @IBAction func addButtonTapped(_ sender: UIBarButtonItem) {
        guard let vc = storyboard?.instantiateViewController(identifier: "AssetItemEditViewController", creator: { coder in
            AssetItemEditViewController(coder: coder, viewModel: AssetItemEditViewModel())
        }) else {
            print("AssetManageViewController: VC 생성 오류")
            return
        }
        vc.presentationStyle = .push
        
        navigationController?.pushViewController(vc, animated: true)
    }
    @IBAction func infoButtonTapped(_ sender: UIButton) {
        infoView.isHidden = false
    }
    @IBAction func closeInfoButtonTapped(_ sender: UIButton) {
        infoView.isHidden = true
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationController?.navigationBar.isHidden = false
        reloadData()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        navigationController?.navigationBar.isHidden = true
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        infoView.layer.shadowColor = UIColor.black.cgColor
        infoView.layer.shadowOpacity = 0.2
        infoView.layer.shadowOffset = CGSize(width: 1, height: 1)
        infoView.layer.shadowRadius = 2
    }
}
