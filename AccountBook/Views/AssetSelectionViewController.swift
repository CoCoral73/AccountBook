//
//  AssetSelectionViewController.swift
//  AccountBook
//
//  Created by 김정원 on 7/19/25.
//

import UIKit

class AssetSelectionViewController: UIViewController {

    @IBOutlet weak var cashButton: UIButton!
    @IBOutlet weak var accountButton: UIButton!
    @IBOutlet weak var debitCardButton: UIButton!
    @IBOutlet weak var creditCardButton: UIButton!
    
    var buttons: [UIButton] = []
    var selectedButton: Int = 5
    
    @IBOutlet weak var tableView: UITableView!
    
    var onAssetSelected: ((AssetItem) -> ())?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        configure()
        configureTableView()
    }
    
    private func configure() {
        buttons = [cashButton, accountButton, debitCardButton, creditCardButton]
    }
    
    @IBAction func PaymentTypeButtonTapped(_ sender: UIButton) {
        buttons.forEach {
            $0.backgroundColor = .systemBackground
        }
        
        sender.backgroundColor = #colorLiteral(red: 1, green: 0.5680983663, blue: 0.6200271249, alpha: 0.2426014073)
        
        selectedButton = sender.tag
        tableView.reloadData()
    }
    

}

extension AssetSelectionViewController: UITableViewDelegate, UITableViewDataSource {
    private func configureTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        
        //최하단 여백 삭제
        tableView.contentInsetAdjustmentBehavior = .never
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let cell = tableView.cellForRow(at: indexPath) as? AssetTableViewCell else { return }
        onAssetSelected?(cell.viewModel.assetItem)
        dismiss(animated: true)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return AssetItemManager.shared.getAssetItems(with: selectedButton).count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: Cell.assetCell, for: indexPath) as! AssetTableViewCell
        
        let item = AssetItemManager.shared.getAssetItems(with: selectedButton)[indexPath.row]
        cell.viewModel = AssetViewModel(assetItem: item)
        
        return cell
    }
    
    override func viewDidLayoutSubviews() {
        tableView.rowHeight = tableView.frame.height / 4
    }
}
