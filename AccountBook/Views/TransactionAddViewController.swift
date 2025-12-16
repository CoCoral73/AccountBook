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
        configureTapGesture()
        configureTextField()
        configureCategoryView()
    }
    
    private func bindViewModel() {
        viewModel.onDidSetTransactionDate = { [weak self] in
            guard let self = self else { return }
            DispatchQueue.main.async {
                self.dateButton.title = self.viewModel.transactionDateString
            }
        }

        viewModel.onRequestDatePickerViewPresentation = { [weak self ] vm in
            guard let self = self else { return }
            showDatePickerView(vm)
        }
        viewModel.onRequestAssetSelectionViewPresentation = { [weak self] vm in
            guard let self = self else { return }
            showAssetSelectionView(vm)
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
    private func configureTapGesture() {
        let tapAmount = UITapGestureRecognizer(target: self, action: #selector(didTapAmountView))
        let tapAsset = UITapGestureRecognizer(target: self, action: #selector(didTapAssetView))
        let tapName = UITapGestureRecognizer(target: self, action: #selector(didTapNameView))
        
        amountView.addGestureRecognizer(tapAmount)
        assetView.addGestureRecognizer(tapAsset)
        nameView.addGestureRecognizer(tapName)
    }
    
    @objc func didTapAmountView(_ sender: UITapGestureRecognizer) {
        //커스텀 키보드 띄우기
    }
    @objc func didTapAssetView(_ sender: UITapGestureRecognizer) {
        viewModel.handleAssetView()
    }
    @objc func didTapNameView(_ sender: UITapGestureRecognizer) {
        nameTextField.becomeFirstResponder()
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
        viewModel.handleDateButton()
    }
    
    private func showDatePickerView(_ vm: DatePickerViewModel) {
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
    private func showAssetSelectionView(_ vm: AssetSelectionViewModel) {
        guard let assetSelectionVC = storyboard?.instantiateViewController(identifier: "AssetSelectionViewController", creator: { coder in
            AssetSelectionViewController(coder: coder, viewModel: vm)
        })
        else {
            fatalError("AssetSelectionViewController 생성 에러")
        }
        
        if let sheet = assetSelectionVC.sheetPresentationController {
            sheet.detents = [.custom { _ in
                return assetSelectionVC.preferredContentSize.height
            }]
        }
        present(assetSelectionVC, animated: true, completion: nil)
    }
    
}

extension TransactionAddViewController: UITextFieldDelegate {
    func configureTextField() {
        nameTextField.delegate = self
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        view.endEditing(true)
    }
}
