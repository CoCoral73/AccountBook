//
//  AddViewController.swift
//  AccountBook
//
//  Created by 김정원 on 7/9/25.
//

import UIKit

class TransactionAddViewController: UIViewController {
    
    @IBOutlet weak var dateButton: UIBarButtonItem!
    @IBOutlet weak var amountView: UIView!
    @IBOutlet weak var amountLabel: UILabel!
    @IBOutlet weak var assetView: UIView!
    @IBOutlet weak var assetLabel: UILabel!
    @IBOutlet weak var nameView: UIView!
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var containerViewForCategory: UIView!
    
    var tableVC: TransactionAddTableViewController?
    
    var viewModel: TransactionAddViewModel
    
    required init?(coder: NSCoder, viewModel: TransactionAddViewModel) {
        self.viewModel = viewModel
        super.init(coder: coder)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        bindViewModel()
        configureUI()
        configureCategoryView()
    }
    
    private func bindViewModel() {
        viewModel.onDidSetTransactionDate = { [weak self] in
            guard let self = self else { return }
            DispatchQueue.main.async {
                self.dateButton.title = self.viewModel.transactionDateString
            }
        }
        viewModel.onRequestTextData = { [weak self] in
            guard let self = self else { return (nil, nil) }
            return (tableVC?.amountTextField.text, tableVC?.nameTextField.text)
        }
        viewModel.onRequestFeedbackForNoData = { [weak self] msg in
            guard let self = self else { return }
            DispatchQueue.main.async {
                self.view.endEditing(true)
                HapticFeedback.notify(.error)
                ToastManager.shared.show(message: msg, in: self.view)
            }
        }
        viewModel.onRequestFeedbackForInvalidData = { [weak self] msg in
            guard let self = self else { return }
            DispatchQueue.main.async {
                self.view.endEditing(true)
                HapticFeedback.notify(.error)
                ToastManager.shared.show(message: msg, in: self.view)
            }
        }
        viewModel.onRequestDismiss = { [weak self] in
            guard let self = self else { return }
            DispatchQueue.main.async {
                self.dismiss(animated: true)
            }
        }
    }
    
    private func configureUI() {
        dateButton.title = viewModel.transactionDateString
    }
    
    private func configureCategoryView() {
        let vm = viewModel.handleCategoryView()
        
        guard let childVC = storyboard?.instantiateViewController(identifier: "CategoryViewController", creator: { coder in
            CategoryViewController(coder: coder, viewModel: vm)
        }) else {
            fatalError("CategoryViewController 생성 에러")
        }
        
        addChild(childVC)
        childVC.view.frame = containerViewForCategory.bounds
        containerViewForCategory.addSubview(childVC.view)
        childVC.didMove(toParent: self)
    }
    
    @IBAction func closeButtonTapped(_ sender: UIBarButtonItem) {
        dismiss(animated: true)
    }
    
    @IBAction func dateButtonTapped(_ sender: UIBarButtonItem) {
        let vm = viewModel.handleDateButton()
        
        guard let dateVC = storyboard?.instantiateViewController(identifier: "DatePickerViewController", creator: { coder in
            DatePickerViewController(coder: coder, viewModel: vm) })
        else {
            fatalError("DatePickerViewController 생성 에러")
        }
        
        if let sheet = dateVC.sheetPresentationController {
            sheet.detents = [.custom { _ in
                return dateVC.preferredContentSize.height
            }]
        }
        present(dateVC, animated: true)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let tableVC = segue.destination as? TransactionAddTableViewController {
            tableVC.viewModel = self.viewModel
            self.tableVC = tableVC
        }
    }
}
