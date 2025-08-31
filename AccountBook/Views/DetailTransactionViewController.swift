//
//  DetailTransactionViewController.swift
//  AccountBook
//
//  Created by 김정원 on 8/18/25.
//

import UIKit

class DetailTransactionViewController: UIViewController {
    
    @IBOutlet weak var paperView: UIView!
    @IBOutlet weak var dateButton: UIButton!
    @IBOutlet weak var isIncomeLabel: UILabel!
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var amountTextField: FormattedTextField!
    @IBOutlet weak var assetTypeLabel: UILabel!
    @IBOutlet weak var categoryButton: UIButton!
    @IBOutlet weak var assetItemButton: UIButton!
    @IBOutlet weak var installmentLabel: UILabel!
    @IBOutlet weak var installmentButton: UIButton!
    @IBOutlet weak var memoTextView: UITextView!
    
    var viewModel: DetailTransactionViewModel
    
    required init?(coder: NSCoder, viewModel: DetailTransactionViewModel) {
        self.viewModel = viewModel
        super.init(coder: coder)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        configurePopGesture()
        configureViewModel()
    }
    
    private func configurePopGesture() {
        navigationController?.interactivePopGestureRecognizer?.delegate = nil
        navigationController?.interactivePopGestureRecognizer?.isEnabled = true
    }
    
    private func configureViewModel() {
        viewModel.onDidSetTransactionDate = { [weak self] in
            guard let self = self else { return }
            dateButton.setTitle(viewModel.dateString, for: .normal)
        }
        viewModel.onDidSetCategory = { [weak self] in
            guard let self = self else { return }
            categoryButton.setTitle(viewModel.categoryString, for: .normal)
        }
        viewModel.onDidSetAssetItem = { [weak self] in
            guard let self = self else { return }
            assetItemButton.setTitle(viewModel.assetItemString, for: .normal)
            assetTypeLabel.text = viewModel.assetTypeString
            installmentLabel.isHidden = viewModel.assetType != .creditCard
        }
        
        dateButton.setTitle(viewModel.dateString, for: .normal)
        isIncomeLabel.text = viewModel.isIncomeString
        nameTextField.text = viewModel.nameString
        amountTextField.text = viewModel.amountString
        assetTypeLabel.text = viewModel.assetTypeString
        categoryButton.setTitle(viewModel.categoryString, for: .normal)
        assetItemButton.setTitle(viewModel.assetItemString, for: .normal)
        //일시불 버튼 처리
        installmentLabel.isHidden = viewModel.assetType != .creditCard
        memoTextView.text = viewModel.memoString
    }
    
    @IBAction func dateButtonTapped(_ sender: UIButton) {
        viewModel.handleDateButton(storyboard: storyboard, fromVC: self)
    }
    
    @IBAction func categoryButtonTapped(_ sender: UIButton) {
        viewModel.handleCategoryButton(storyboard: storyboard, fromVC: self)
    }
    
    @IBAction func assetItemButtonTapped(_ sender: UIButton) {
        viewModel.handleAssetItemButton(storyboard: storyboard, fromVC: self)
    }
    
    @IBAction func installmentButtonTapped(_ sender: UIButton) {
    }
    
    @IBAction func backButtonTapped(_ sender: UIBarButtonItem) {
        //뒤로가기 버튼
        navigationController?.popViewController(animated: true)
    }
    
    @IBAction func removeButtonTapped(_ sender: UIBarButtonItem) {
        //휴지통 버튼
        viewModel.handleRemoveButton(self)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        viewModel.saveUpdatedTransaction(name: nameTextField.text ?? "", amount: amountTextField.text ?? "0", memo: memoTextView.text)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        // 그림자 설정
        paperView.layer.shadowColor   = UIColor.black.cgColor
        paperView.layer.shadowOpacity = 0.2
        paperView.layer.shadowOffset  = CGSize(width: 0, height: 1)
        paperView.layer.shadowRadius  = 6
    }
}

extension DetailTransactionViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
    }
}
