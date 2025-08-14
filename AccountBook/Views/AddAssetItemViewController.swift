//
//  AddAssetItemViewController.swift
//  AccountBook
//
//  Created by 김정원 on 8/14/25.
//

import UIKit

class AddAssetItemViewController: UIViewController {

    @IBOutlet weak var segControl: UISegmentedControl!
    
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var balanceTextField: UITextField!
    @IBOutlet weak var selectAccountButton: UIButton!
    
    @IBOutlet weak var accountStackView: UIStackView!
    @IBOutlet weak var cardStackView: UIStackView!
    @IBOutlet weak var creditCardStackView: UIStackView!
    
    var viewModel: AddAssetItemViewModel
    
    required init?(coder: NSCoder, viewModel: AddAssetItemViewModel) {
        self.viewModel = viewModel
        super.init(coder: coder)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        configureSegControl()
        configureSelectAccountButton()
    }
    
    func configureSegControl() {
        segControl.selectedSegmentIndex = viewModel.selectedSegmentIndex
        segControlChanged(segControl)
    }
    
    @IBAction func segControlChanged(_ sender: UISegmentedControl) {
        let idx = segControl.selectedSegmentIndex
        
        accountStackView.isHidden = (idx != 0)
        cardStackView.isHidden = (idx == 0)
        creditCardStackView.isHidden = (idx != 2)
        
        viewModel.setType(with: AssetType(rawValue: idx + 1)!)
    }
    
    func configureSelectAccountButton() {
        var items: [UIAction] = []
        items.append(UIAction(title: "선택 안함") { _ in
            self.viewModel.linkedAccount = nil
            self.selectAccountButton.setTitle("선택 안함", for: .normal)
        })
        
        items.append(contentsOf: AssetItemManager.shared.bankAccount.map { account in
          UIAction(title: account.name, image: nil) { _ in
              self.viewModel.linkedAccount = account
              self.selectAccountButton.setTitle(account.name, for: .normal)
          }
        })
        
        let menu = UIMenu(children: items)
        selectAccountButton.menu = menu
        selectAccountButton.showsMenuAsPrimaryAction = true
    }
    
    @IBAction func closeButtonTapped(_ sender: UIBarButtonItem) {
        dismiss(animated: true)
    }
    
    @IBAction func addButtonTapped(_ sender: UIBarButtonItem) {
        guard let name = nameTextField.text, let balance = Int64(balanceTextField.text ?? "") else { return }
        viewModel.name = name
        viewModel.balance = balance
        
        viewModel.handleAddButton()
        dismiss(animated: true)
    }
    
}
