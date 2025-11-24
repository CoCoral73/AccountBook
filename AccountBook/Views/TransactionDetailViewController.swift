//
//  DetailTransactionViewController.swift
//  AccountBook
//
//  Created by 김정원 on 8/18/25.
//

import UIKit

class TransactionDetailViewController: UIViewController, ThemeApplicable {
    
    @IBOutlet weak var navigationBar: UINavigationBar!
    @IBOutlet weak var backView: UIView!
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
    @IBOutlet weak var removeInstallmentButton: UIButton!
    
    var viewModel: TransactionDetailViewModel
    
    required init?(coder: NSCoder, viewModel: TransactionDetailViewModel) {
        self.viewModel = viewModel
        super.init(coder: coder)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        startObservingTheme()
        configurePopGesture()
        bindViewModel()
        configureUIByViewModel()
        configureKeyboardAccessory()
        nameTextField.delegate = self
    }
    
    //ThemeApplicable
    func applyTheme(_ theme: any AppTheme) {
        view.backgroundColor = theme.baseColor
        
        let appearance = UINavigationBarAppearance()
        appearance.configureWithTransparentBackground()
        navigationBar.standardAppearance = appearance
        
        removeInstallmentButton.backgroundColor = theme.accentColor
    }
    
    private func bindViewModel() {
        viewModel.onDidSetTransactionDate = { [weak self] in
            guard let self = self else { return }
            DispatchQueue.main.async {
                self.dateButton.setTitle(self.viewModel.dateString, for: .normal)
            }
        }
        viewModel.onDidSetCategory = { [weak self] in
            guard let self = self else { return }
            DispatchQueue.main.async {
                self.categoryButton.setTitle(self.viewModel.categoryString, for: .normal)
            }
        }
        viewModel.onDidSetAssetItem = { [weak self] in
            guard let self = self else { return }
            DispatchQueue.main.async {
                self.assetItemButton.setTitle(self.viewModel.assetItemString, for: .normal)
                self.assetTypeLabel.text = self.viewModel.assetTypeString
                self.installmentLabel.isHidden = self.viewModel.assetType != .creditCard
                self.installmentButton.isHidden = self.viewModel.assetType != .creditCard
            }
        }
        viewModel.onDidSetInstallment = { [weak self] in
            guard let self = self else { return }
            DispatchQueue.main.async {
                self.configureUIByViewModel()
            }
        }
        viewModel.onRequestDeleteInstallmentAlert = { [weak self] config in
            guard let self = self else { return }
            let alert = UIAlertController(title: config.title, message: config.message, preferredStyle: .actionSheet)
            let success = UIAlertAction(title: "확인", style: .destructive) { _ in
                self.viewModel.confirmDeleteInstallment()
            }
            let cancel = UIAlertAction(title: "취소", style: .cancel)
            alert.addAction(success)
            alert.addAction(cancel)
            present(alert, animated: true)
        }
        viewModel.onRequestDeleteAlert = { [weak self] config in
            guard let self = self else { return }
            let alert = UIAlertController(title: config.title, message: config.message, preferredStyle: .actionSheet)
            let success = UIAlertAction(title: "확인", style: .destructive) { _ in
                HapticFeedback.notify(.success)
                self.viewModel.confirmDelete()
            }
            let cancel = UIAlertAction(title: "취소", style: .cancel)
            alert.addAction(success)
            alert.addAction(cancel)
            present(alert, animated: true)
        }
        viewModel.onRequestBlockPopAlert = { [weak self] in
            guard let self = self else { return }
            showAlertBlockingPop()
        }
        viewModel.onRequestSaveAlert = { [weak self] config in
            guard let self = self else { return }
            let alert = UIAlertController(title: config.title, message: config.message, preferredStyle: .alert)
            let success = UIAlertAction(title: "저장", style: .default) { _ in
                self.viewModel.confirmSave(name: self.nameTextField.text, amount: self.amountTextField.text, memo: self.memoTextView.text)
            }
            let cancel = UIAlertAction(title: "취소", style: .cancel)
            alert.addAction(success)
            alert.addAction(cancel)
            present(alert, animated: true)
        }
        viewModel.onRequestPop = { [weak self] in
            guard let self = self else { return }
            navigationController?.popViewController(animated: true)
        }
    }
    
    private func configureUIByViewModel() {
        dateButton.setTitle(viewModel.dateString, for: .normal)
        isIncomeLabel.text = viewModel.isIncomeString
        nameTextField.text = viewModel.nameString
        amountTextField.text = viewModel.amountString
        assetTypeLabel.text = viewModel.assetTypeString
        categoryButton.setTitle(viewModel.categoryString, for: .normal)
        assetItemButton.setTitle(viewModel.assetItemString, for: .normal)
        installmentLabel.isHidden = viewModel.assetType != .creditCard
        installmentButton.isHidden = viewModel.assetType != .creditCard
        installmentButton.setTitle(viewModel.installmentString, for: .normal)
        memoTextView.text = viewModel.memoString
        removeInstallmentButton.isHidden = viewModel.canEdit
    }
    
    private func configureKeyboardAccessory() {
        let toolbar = UIToolbar()
        toolbar.sizeToFit()                      // 키보드 폭에 맞춰 높이 자동 조정
        
        let complete = UIBarButtonItem(title: "완료", style: .plain, target: self, action: #selector(dismissKeyboard))
        let flexible = UIBarButtonItem(systemItem: .flexibleSpace)
        
        toolbar.items = [flexible, complete]
        
        amountTextField.inputAccessoryView = toolbar
        memoTextView.inputAccessoryView = toolbar
    }
    
    @objc func dismissKeyboard(_ sender: UIBarButtonItem) {
        view.endEditing(true)
    }
    
    @IBAction func dateButtonTapped(_ sender: UIButton) {
        if !viewModel.canEdit {
            HapticFeedback.notify(.error)
            sender.shake()
            ToastManager.shared.show(message: "할부가 적용되어 수정할 수 없습니다.", in: view)
            return
        }
        
        let vm = viewModel.handleDateButton()
        guard let dateVC = storyboard?.instantiateViewController(identifier: "DatePickerViewController", creator: { coder in
            DatePickerViewController(coder: coder, viewModel: vm)
        }) else {
            fatalError("DatePickerViewController 생성 에러")
        }
        
        if let sheet = dateVC.sheetPresentationController {
            sheet.detents = [.custom { _ in
                return dateVC.preferredContentSize.height
            }]
        }
        present(dateVC, animated: true)
    }
    
    @IBAction func categoryButtonTapped(_ sender: UIButton) {
        let vm = viewModel.handleCategoryButton()
        guard let categoryVC = storyboard?.instantiateViewController(identifier: "CategoryViewController", creator: { coder in
            CategoryViewController(coder: coder, viewModel: vm)
        }) else {
            fatalError("CategoryViewController 생성 에러")
        }
        
        if let sheet = categoryVC.sheetPresentationController {
            sheet.detents = [.medium()]
            sheet.prefersScrollingExpandsWhenScrolledToEdge = true
        }
        
        present(categoryVC, animated: true)
    }
    
    @IBAction func assetItemButtonTapped(_ sender: UIButton) {
        if !viewModel.canEdit {
            HapticFeedback.notify(.error)
            sender.shake()
            ToastManager.shared.show(message: "할부가 적용되어 수정할 수 없습니다.", in: view)
            return
        }
        
        let vm = viewModel.handleAssetItemButton()
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
    
    @IBAction func installmentButtonTapped(_ sender: UIButton) {
        if !viewModel.canEdit {
            HapticFeedback.notify(.error)
            sender.shake()
            ToastManager.shared.show(message: "할부가 적용되어 수정할 수 없습니다.", in: view)
            return
        }
        
        let vm = viewModel.handleInstallmentButton()
        guard let installmentVC = storyboard?.instantiateViewController(identifier: "InstallmentViewController", creator: { coder in
            InstallmentViewController(coder: coder, viewModel: vm)
        })
        else {
            fatalError("InstallmentViewController 생성 에러")
        }
    
        navigationController?.pushViewController(installmentVC, animated: true)
    }
    
    @IBAction func removeInstallmentButtonTapped(_ sender: UIButton) {
        viewModel.handleRemoveInstallmentButton()
    }
    
    @IBAction func removeButtonTapped(_ sender: UIButton) {
        viewModel.handleRemoveButton()
    }
    
    @IBAction func backButtonTapped(_ sender: UIBarButtonItem) {
        viewModel.handleBackButton()
    }
    
    @IBAction func saveButtonTapped(_ sender: UIBarButtonItem) {
        viewModel.handleSaveButton()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        applyInitialTheme()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        // 그림자 설정
        paperView.layer.shadowColor   = UIColor.black.cgColor
        paperView.layer.shadowOpacity = 0.2
        paperView.layer.shadowOffset  = CGSize(width: 0, height: 1)
        paperView.layer.shadowRadius  = 6
        
        let path = UIBezierPath(roundedRect: removeInstallmentButton.bounds, cornerRadius: removeInstallmentButton.bounds.width / 2)
        removeInstallmentButton.layer.shadowPath = path.cgPath
        removeInstallmentButton.layer.shadowColor   = UIColor.black.cgColor
        removeInstallmentButton.layer.shadowOpacity = 0.2
        removeInstallmentButton.layer.shadowOffset  = CGSize(width: 0, height: 2)
        removeInstallmentButton.layer.shadowRadius  = 6
    }
    
    deinit {
        stopObservingTheme()
    }
}

extension TransactionDetailViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
        super.touchesBegan(touches, with: event)
    }
}
