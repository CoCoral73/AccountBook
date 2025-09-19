//
//  AddAssetItemViewController.swift
//  AccountBook
//
//  Created by 김정원 on 8/14/25.
//

import UIKit

class AssetItemAddViewController: UIViewController {

    @IBOutlet weak var segControl: UISegmentedControl!
    
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var balanceTextField: UITextField!
    @IBOutlet weak var accountButton: AutoDismissKeyboardButton!
    @IBOutlet weak var withdrawalDayButton: AutoDismissKeyboardButton!
    @IBOutlet weak var startDayButton: AutoDismissKeyboardButton!
    
    @IBOutlet weak var accountStackView: UIStackView!
    @IBOutlet weak var cardStackView: UIStackView!
    @IBOutlet weak var creditCardStackView: UIStackView!
    
    var viewModel: AssetItemAddViewModel
    
    required init?(coder: NSCoder, viewModel: AssetItemAddViewModel) {
        self.viewModel = viewModel
        super.init(coder: coder)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        configureSegControl()
        configureAccountButton()
        configureUI()
        configureTextField()
        configureTapGesture()
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
    
    func configureAccountButton() {
        var items: [UIAction] = []
        items.append(UIAction(title: "선택 안함") { _ in
            self.viewModel.setLinkedAccount(with: nil)
            self.accountButton.setTitle("선택 안함", for: .normal)
        })
        
        items.append(contentsOf: AssetItemManager.shared.bankAccount.map { account in
          UIAction(title: account.name, image: nil) { _ in
              self.viewModel.setLinkedAccount(with: account)
              self.accountButton.setTitle(account.name, for: .normal)
          }
        })
        
        let menu = UIMenu(children: items)
        accountButton.menu = menu
        accountButton.showsMenuAsPrimaryAction = true
    }
    
    func configureUI() {
        withdrawalDayButton.setTitle(viewModel.selectWithdrawlDateButtonTitle, for: .normal)
        startDayButton.setTitle(viewModel.selectStartDateButtonTitle, for: .normal)
    }
    
    func configureTapGesture() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
    
    @IBAction func dayButtonTapped(_ sender: UIButton) {
        viewModel.handleDayButton(tag: sender.tag, storyboard: storyboard, fromVC: self)
    }
    
    
    @IBAction func closeButtonTapped(_ sender: UIBarButtonItem) {
        dismiss(animated: true)
    }
    
    @IBAction func addButtonTapped(_ sender: UIBarButtonItem) {
        guard let name = nameTextField.text else { return }
        viewModel.setName(with: name)
        
        if segControl.selectedSegmentIndex == 0 {
            let balance = Int64(balanceTextField.text ?? "") ?? 0
            viewModel.setBalance(with: balance)
        }
        
        viewModel.handleAddButton()
        dismiss(animated: true)
    }
    
}

extension AssetItemAddViewController: UITextFieldDelegate {
    
    func configureTextField() {
        nameTextField.delegate = self
        balanceTextField.delegate = self
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if segControl.selectedSegmentIndex == 0 && textField == nameTextField {
            balanceTextField.becomeFirstResponder()
        } else {
            view.endEditing(true)
        }
    }
}
