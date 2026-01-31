//
//  AssetSelectionViewController.swift
//  AccountBook
//
//  Created by 김정원 on 7/19/25.
//

import UIKit

class AssetSelectionViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    required init?(coder: NSCoder, viewModel: AssetSelectionViewModel) {
        self.viewModel = viewModel
        super.init(coder: coder)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @IBOutlet weak var typeTableView: UITableView!
    @IBOutlet weak var itemTableView: UITableView!
    
    var viewModel: AssetSelectionViewModel
    var selectedType: AssetType?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        configureTableView()
        configureInitialSettingIfNeeded()
        preferredContentSize.height = 360
    }

    private func configureTableView() {
        typeTableView.delegate = self
        typeTableView.dataSource = self
        
        itemTableView.delegate = self
        itemTableView.dataSource = self
        
        //최하단 여백 삭제
        typeTableView.contentInsetAdjustmentBehavior = .never
        itemTableView.contentInsetAdjustmentBehavior = .never
    }
    
    private func configureInitialSettingIfNeeded() {
        guard viewModel.type == .transfer else { return }
        
        typeTableView.selectRow(at: IndexPath(row: 0, section: 0), animated: false, scrollPosition: .none)
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if tableView == typeTableView {
            viewModel.setSelectedType(indexPath.row)
            itemTableView.reloadData()
        } else {
            if let vm = viewModel.didSelectRowAt(indexPath.row) {
                vm.onDidAddAssetItem = { [weak self] in
                    guard let self = self else { return }
                    self.itemTableView.reloadData()
                }
                
                guard let addAssetVC = storyboard?.instantiateViewController(identifier: "AssetItemEditViewController", creator: { coder in AssetItemEditViewController(coder: coder, viewModel: vm) })
                else {
                    fatalError("AssetItemEditViewController 생성 에러")
                }
                
                addAssetVC.modalPresentationStyle = .fullScreen
                present(addAssetVC, animated: true)
            } else {
                dismiss(animated: true)
            }
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView == typeTableView {
            return viewModel.assetTypes.count
        } else {
            return viewModel.numberOfRowsInSection
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if tableView == typeTableView {
            let cell = tableView.dequeueReusableCell(withIdentifier: Cell.assetTypeCell, for: indexPath) as! AssetTypeTableViewCell
            
            cell.model = viewModel.assetTypes[indexPath.row]
            
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: Cell.assetItemCell, for: indexPath) as! AssetItemTableViewCell
            
            if viewModel.selectedType != .cash && indexPath.row == viewModel.numberOfRowsInSection - 1 { //자산 추가 셀
                cell.model = nil
            } else {
                let item = viewModel.assetItems[indexPath.row]
                cell.model = item
            }
            
            return cell
        }
    }
    
    override func viewDidLayoutSubviews() {
        typeTableView.rowHeight = typeTableView.frame.height / 4
        itemTableView.rowHeight = itemTableView.frame.height / 4
    }
}
