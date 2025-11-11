//
//  AssetItemEditViewController.swift
//  AccountBook
//
//  Created by 김정원 on 8/14/25.
//

import UIKit

class AssetItemEditViewController: UIViewController {

    @IBOutlet weak var navItem: UINavigationItem!
    @IBOutlet weak var segControl: UISegmentedControl!
    
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var balanceTextField: UITextField!
    @IBOutlet weak var accountButton: AutoDismissKeyboardButton!
    @IBOutlet weak var withdrawalDayButton: AutoDismissKeyboardButton!
    @IBOutlet weak var startDayButton: AutoDismissKeyboardButton!
    
    @IBOutlet weak var accountStackView: UIStackView!
    @IBOutlet weak var cardStackView: UIStackView!
    @IBOutlet weak var creditCardStackView: UIStackView!
    
    @IBOutlet weak var topConstraint: NSLayoutConstraint!
    
    var viewModel: AssetItemEditViewModel
    var presentationStyle: PresentationStyle = .modal
    
    required init?(coder: NSCoder, viewModel: AssetItemEditViewModel) {
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
        
        viewModel.setType(with: idx)
        
        accountStackView.isHidden = viewModel.isHiddenForAccount
        cardStackView.isHidden = viewModel.isHiddenForCard
        creditCardStackView.isHidden = viewModel.isHiddenForCredit
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
        navItem.title = viewModel.title
        segControl.isHidden = viewModel.isHiddenForSegControl
        topConstraint.constant = viewModel.topConstraintConstant
        nameTextField.isEnabled = viewModel.isEnabledForNameTextField
        nameTextField.text = viewModel.nameTextFieldString
        balanceTextField.text = viewModel.balanceTextFieldString
        accountButton.setTitle(viewModel.accountButtonTitleString, for: .normal)
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
        close()
    }
    
    @IBAction func doneButtonTapped(_ sender: UIBarButtonItem) {
        guard let name = nameTextField.text, name != "" else {
            ToastManager.shared.show(message: "이름을 입력해주세요", in: view)
            HapticFeedback.notify(.error)
            return
        }
        
        viewModel.setName(with: name)
        
        let balance = Int64(balanceTextField.text ?? "") ?? 0
        viewModel.setBalance(with: balance)
        
        viewModel.handleDoneButton()
        close()
    }
    
    func close() {
        switch presentationStyle {
        case .modal:
            dismiss(animated: true)
        case .push:
            self.navigationController?.popViewController(animated: true)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.isHidden = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.navigationBar.isHidden = false
    }
}

extension AssetItemEditViewController: UITextFieldDelegate {
    
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
