//
//  AssetSelectionViewController.swift
//  AccountBook
//
//  Created by 김정원 on 7/19/25.
//

import UIKit

class AssetSelectionViewController: UIViewController {
    
    required init?(coder: NSCoder, viewModel: AssetSelectionViewModel) {
        self.viewModel = viewModel
        super.init(coder: coder)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @IBOutlet weak var cashButton: UIButton!
    @IBOutlet weak var accountButton: UIButton!
    @IBOutlet weak var debitCardButton: AutoUpdateColorButton!
    @IBOutlet weak var creditCardButton: AutoUpdateColorButton!
    
    var viewModel: AssetSelectionViewModel
    var buttons: [UIButton] = []
    var selectedButtonTag: Int = 5
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        configure()
        configureTableView()
        
        preferredContentSize.height = 375
    }
    
    private func configure() {
        buttons = [cashButton, accountButton, debitCardButton, creditCardButton]
        if viewModel.type == .income {
            debitCardButton.setInvisible(true)
            creditCardButton.setInvisible(true)
        }
    }
    
    @IBAction func AssetTypeButtonTapped(_ sender: UIButton) {
        if selectedButtonTag <= 3 {
            buttons[selectedButtonTag].backgroundColor = .systemBackground
        }
        
        sender.backgroundColor = #colorLiteral(red: 1, green: 0.5680983663, blue: 0.6200271249, alpha: 0.2426014073)
        
        selectedButtonTag = sender.tag
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
        guard let cell = tableView.cellForRow(at: indexPath) as? AssetItemTableViewCell else { return }
        
        if let model = cell.model {
            viewModel.didSelectRowAt(with: model)
            dismiss(animated: true)
        } else {    //자산 추가 뷰로 이동
            let vm = AssetItemEditViewModel(type: AssetType(rawValue: Int16(selectedButtonTag))!)
            vm.onDidAddAssetItem = { [weak self] in
                guard let self = self else { return }
                
                self.tableView.reloadData()
            }
            
            guard let addAssetVC = storyboard?.instantiateViewController(identifier: "AssetItemEditViewController", creator: { coder in AssetItemEditViewController(coder: coder, viewModel: vm) })
            else {
                fatalError("AssetItemEditViewController 생성 에러")
            }
            
            addAssetVC.modalPresentationStyle = .fullScreen
            present(addAssetVC, animated: true)
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let type = AssetType(rawValue: Int16(selectedButtonTag)) else { return 0 }
        return AssetItemManager.shared.getAssetItems(with: type).count + (selectedButtonTag != 0 ? 1 : 0)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: Cell.assetCell, for: indexPath) as! AssetItemTableViewCell
        
        if selectedButtonTag != 0 && indexPath.row == tableView.numberOfRows(inSection: 0) - 1 { //자산 추가 셀
            cell.model = nil
        } else {
            let item = AssetItemManager.shared.getAssetItems(with: AssetType(rawValue: Int16(selectedButtonTag))!)[indexPath.row]
            cell.model = item
        }
        
        return cell
    }
    
    override func viewDidLayoutSubviews() {
        tableView.rowHeight = tableView.frame.height / 4
    }
}
