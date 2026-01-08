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
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if tableView == typeTableView {
            guard let cell = tableView.cellForRow(at: indexPath) as? AssetTypeTableViewCell else { return }
            
            if let model = cell.model {
                selectedType = model
                itemTableView.reloadData()
            }
        } else {
            guard let cell = tableView.cellForRow(at: indexPath) as? AssetItemTableViewCell else { return }
            
            if let model = cell.model {
                viewModel.didSelectRowAt(with: model)
                dismiss(animated: true)
            } else {    //자산 추가 뷰로 이동
                let vm = AssetItemEditViewModel(type: selectedType!)
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
            }
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView == typeTableView {
            return viewModel.assetTypes.count
        } else {
            guard let type = selectedType else { return 0 }
            return AssetItemManager.shared.getAssetItems(with: type).count + (type != .cash ? 1 : 0)
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if tableView == typeTableView {
            let cell = tableView.dequeueReusableCell(withIdentifier: Cell.assetTypeCell, for: indexPath) as! AssetTypeTableViewCell
            
            cell.model = viewModel.assetTypes[indexPath.row]
            
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: Cell.assetItemCell, for: indexPath) as! AssetItemTableViewCell
            
            if selectedType != .cash && indexPath.row == tableView.numberOfRows(inSection: 0) - 1 { //자산 추가 셀
                cell.model = nil
            } else {
                let item = AssetItemManager.shared.getAssetItems(with: selectedType!)[indexPath.row]
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
