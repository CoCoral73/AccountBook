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
    @IBOutlet weak var selectAccountButton: AutoDismissKeyboardButton!
    @IBOutlet weak var selectWithdrawalDateButton: AutoDismissKeyboardButton!
    @IBOutlet weak var selectStartDateButton: AutoDismissKeyboardButton!
    
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
        configureSelectAccountButton()
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
    
    func configureSelectAccountButton() {
        var items: [UIAction] = []
        items.append(UIAction(title: "선택 안함") { _ in
            self.viewModel.setLinkedAccount(with: nil)
            self.selectAccountButton.setTitle("선택 안함", for: .normal)
        })
        
        items.append(contentsOf: AssetItemManager.shared.bankAccount.map { account in
          UIAction(title: account.name, image: nil) { _ in
              self.viewModel.setLinkedAccount(with: account)
              self.selectAccountButton.setTitle(account.name, for: .normal)
          }
        })
        
        let menu = UIMenu(children: items)
        selectAccountButton.menu = menu
        selectAccountButton.showsMenuAsPrimaryAction = true
    }
    
    func configureUI() {
        selectWithdrawalDateButton.setTitle(viewModel.selectWithdrawlDateButtonTitle, for: .normal)
        selectStartDateButton.setTitle(viewModel.selectStartDateButtonTitle, for: .normal)
    }
    
    func configureTapGesture() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
    
    @IBAction func selectDateButtonTapped(_ sender: UIButton) {
        let pickerVC = storyboard?.instantiateViewController(withIdentifier: "DayPickerViewController") as! DayPickerViewController
        pickerVC.titleString = sender.tag == 0 ? "출금일" : "시작일"
        pickerVC.onDidSelectDay = { (title, day) in
            if title == "출금일" {
                self.viewModel.setWithdrawalDay(with: day)
                self.selectWithdrawalDateButton.setTitle(self.viewModel.selectWithdrawlDateButtonTitle, for: .normal)
            } else if title == "시작일" {
                self.viewModel.setStartDay(with: day)
                self.selectStartDateButton.setTitle(self.viewModel.selectStartDateButtonTitle, for: .normal)
            }
        }
        
        pickerVC.modalPresentationStyle = .custom
        pickerVC.transitioningDelegate = self
        present(pickerVC, animated: true)
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

//MARK: Month Picker View, Custom Height
extension AssetItemAddViewController: UIViewControllerTransitioningDelegate {
    func presentationController(forPresented presented: UIViewController, presenting: UIViewController?, source: UIViewController) -> UIPresentationController? {
        return DayPickerPresentationController(presentedViewController: presented, presenting: presentingViewController)
    }
}
class DayPickerPresentationController: UIPresentationController {
    override var frameOfPresentedViewInContainerView: CGRect {
        guard let bounds = containerView?.bounds else { return .zero }
        let height = 300 + containerView!.safeAreaInsets.bottom
        return CGRect(x: 0, y: bounds.height - height, width: bounds.width, height: height)
    }
}
