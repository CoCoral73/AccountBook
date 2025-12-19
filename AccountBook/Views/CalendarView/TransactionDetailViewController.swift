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
    @IBOutlet weak var amountLabel: UILabel!
    @IBOutlet weak var assetTypeLabel: UILabel!
    @IBOutlet weak var categoryButton: UIButton!
    @IBOutlet weak var assetItemButton: UIButton!
    @IBOutlet weak var installmentView: UIView!
    @IBOutlet weak var installmentLabel: UILabel!
    @IBOutlet weak var installmentButton: UIButton!
    @IBOutlet weak var isCompletedView: UIView!
    @IBOutlet weak var isCompletedButton: UIButton!
    @IBOutlet weak var memoTextView: UITextView!
    
    private let engine = CalculatorEngine()
    private let keypad = NumericKeypadView.loadFromNib()
    private var bottomConstraint: NSLayoutConstraint!
    
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
        configureUI()
        configureTapGesture()
        configureKeypadLayout()
        configureKeyboardAccessory()
        nameTextField.delegate = self
    }
    
    //ThemeApplicable
    func applyTheme(_ theme: any AppTheme) {
        view.backgroundColor = theme.baseColor
        
        let appearance = UINavigationBarAppearance()
        appearance.configureWithTransparentBackground()
        navigationBar.standardAppearance = appearance
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
                self.installmentView.isHidden = self.viewModel.isHiddenForInstallment
                self.isCompletedView.isHidden = self.viewModel.isHiddenForIsCompleted
                self.isCompletedButton.setTitle(self.viewModel.titleForIsCompleted, for: .normal)
            }
        }
        viewModel.onDidSetInstallment = { [weak self] in
            guard let self = self else { return }
            DispatchQueue.main.async {
                self.configureUI()
            }
        }
        viewModel.onDidSetIsCompleted = { [weak self] in
            guard let self = self else { return }
            DispatchQueue.main.async {
                self.isCompletedButton.setTitle(self.viewModel.titleForIsCompleted, for: .normal)
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
            DispatchQueue.main.async {
                self.present(alert, animated: true)
            }
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
            DispatchQueue.main.async {
                self.present(alert, animated: true)
            }
        }
        viewModel.onRequestBlockPopAlert = { [weak self] in
            guard let self = self else { return }
            DispatchQueue.main.async {
                self.showAlertBlockingPop()
            }
        }
        viewModel.onRequestSaveAlert = { [weak self] config in
            guard let self = self else { return }
            let alert = UIAlertController(title: config.title, message: config.message, preferredStyle: .actionSheet)
            let success = UIAlertAction(title: "저장", style: .default) { _ in
                self.viewModel.confirmSave(name: self.nameTextField.text, memo: self.memoTextView.text)
            }
            let cancel = UIAlertAction(title: "취소", style: .cancel)
            alert.addAction(success)
            alert.addAction(cancel)
            DispatchQueue.main.async {
                self.present(alert, animated: true)
            }
        }
        viewModel.onRequestSaveAlertBeforeInstallment = { [weak self] config in
            guard let self = self else { return }
            let alert = UIAlertController(title: config.title, message: config.message, preferredStyle: .actionSheet)
            let success = UIAlertAction(title: "저장", style: .default) { _ in
                self.viewModel.confirmSave(name: self.nameTextField.text, memo: self.memoTextView.text)
                self.viewModel.handleInstallmentFlow()
            }
            let cancel = UIAlertAction(title: "취소", style: .cancel)
            alert.addAction(success)
            alert.addAction(cancel)
            DispatchQueue.main.async {
                self.present(alert, animated: true)
            }
        }
        viewModel.onRequestSaveAlertBeforeIsCompleted = { [weak self] config in
            guard let self = self else { return }
            let alert = UIAlertController(title: config.title, message: config.message, preferredStyle: .actionSheet)
            let success = UIAlertAction(title: "저장", style: .default) { _ in
                self.viewModel.confirmSave(name: self.nameTextField.text, memo: self.memoTextView.text)
                self.viewModel.requestIsCompletedAlert()
            }
            let cancel = UIAlertAction(title: "취소", style: .cancel)
            alert.addAction(success)
            alert.addAction(cancel)
            DispatchQueue.main.async {
                self.present(alert, animated: true)
            }
        }
        viewModel.onRequestIsCompletedAlert = { [weak self] config in
            guard let self = self else { return }
            let alert = UIAlertController(title: config.title, message: config.message, preferredStyle: .actionSheet)
            let success = UIAlertAction(title: "확인", style: .default) { _ in
                self.viewModel.confirmIsCompleted()
            }
            let cancel = UIAlertAction(title: "취소", style: .cancel)
            alert.addAction(success)
            alert.addAction(cancel)
            DispatchQueue.main.async {
                self.present(alert, animated: true)
            }
        }
        viewModel.onRequestPop = { [weak self] in
            guard let self = self else { return }
            DispatchQueue.main.async {
                self.navigationController?.popViewController(animated: true)
            }
        }
        viewModel.onShowInstallmentView = { [weak self] vm in
            guard let self = self else { return }
            DispatchQueue.main.async {
                self.showInstallmentView(vm)
            }
        }
    }
    
    private func configureUI() {
        dateButton.setTitle(viewModel.dateString, for: .normal)
        isIncomeLabel.text = viewModel.isIncomeString
        nameTextField.text = viewModel.nameString
        amountLabel.text = viewModel.amountString
        assetTypeLabel.text = viewModel.assetTypeString
        categoryButton.setTitle(viewModel.categoryString, for: .normal)
        assetItemButton.setTitle(viewModel.assetItemString, for: .normal)
        installmentView.isHidden = viewModel.isHiddenForInstallment
        installmentButton.setTitle(viewModel.installmentString, for: .normal)
        isCompletedView.isHidden = viewModel.isHiddenForIsCompleted
        isCompletedButton.setTitle(viewModel.titleForIsCompleted, for: .normal)
        memoTextView.text = viewModel.memoString
    }
    
    private func configureTapGesture() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(didTapAmountLabel))
        amountLabel.addGestureRecognizer(tap)

        let viewTap = UITapGestureRecognizer(target: self, action: #selector(didTapView))
        viewTap.cancelsTouchesInView = false
        viewTap.delegate = self
        view.addGestureRecognizer(viewTap)
    }
    
    @objc func didTapView(_ sender: UITapGestureRecognizer) {
        view.endEditing(true)
        keypadDidHide()
    }
    
    @objc func didTapAmountLabel(_ sender: UITapGestureRecognizer) {
        view.endEditing(true)
        showNumericKeypad()
    }
    
    private func configureKeyboardAccessory() {
        let toolbar = UIToolbar()
        toolbar.sizeToFit()                      // 키보드 폭에 맞춰 높이 자동 조정
        
        let complete = UIBarButtonItem(title: "완료", style: .plain, target: self, action: #selector(dismissKeyboard))
        let flexible = UIBarButtonItem(systemItem: .flexibleSpace)
        
        toolbar.items = [flexible, complete]
        
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
        checkSaveState()
        viewModel.handleInstallmentButton()
    }
    
    @IBAction func isCompletedButtonTapped(_ sender: UIButton) {
        checkSaveState()
        viewModel.handleIsCompletedButton()
    }
    
    func checkSaveState() {
        viewModel.checkSaveState(name: nameTextField.text, memo: memoTextView.text)
    }
    
    func showInstallmentView(_ vm: InstallmentViewModel) {
        guard let installmentVC = storyboard?.instantiateViewController(identifier: "InstallmentViewController", creator: { coder in
            InstallmentViewController(coder: coder, viewModel: vm)
        }) else {
            fatalError("InstallmentVC 생성 에러")
        }
        
        navigationController?.pushViewController(installmentVC, animated: true)
    }
    
    @IBAction func removeButtonTapped(_ sender: UIButton) {
        viewModel.handleRemoveButton()
    }
    
    @IBAction func backButtonTapped(_ sender: UIBarButtonItem) {
        checkSaveState()
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
    }
    
    deinit {
        stopObservingTheme()
    }
}

extension TransactionDetailViewController: UIGestureRecognizerDelegate {
    func configurePopGesture() {
        navigationController?.interactivePopGestureRecognizer?.delegate = self
    }
    
    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        checkSaveState()
        if viewModel.state == .modified {
            showAlertBlockingPop()
            return false
        }
        return true
    }
    
    func showAlertBlockingPop() {
        let alert = UIAlertController(title: "경고", message: "저장되지 않은 변경사항이 있습니다.\n저장하시겠습니까?",
            preferredStyle: .alert
        )

        alert.addAction(UIAlertAction(title: "아니오", style: .cancel) { [weak self] _ in
            guard let self = self else { return }
            viewModel.doNotSaveAndExit()
            navigationController?.popViewController(animated: true)
        })
        alert.addAction(UIAlertAction(title: "저장", style: .default) { [weak self] _ in
            guard let self = self else { return }
            viewModel.confirmSave(name: nameTextField.text, memo: memoTextView.text)
            navigationController?.popViewController(animated: true)
        })

        present(alert, animated: true)
    }
}

extension TransactionDetailViewController: NumericKeypadDelegate {
    func configureKeypadLayout() {
        keypad.delegate = self
        
        view.addSubview(keypad)
        keypad.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            keypad.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            keypad.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            keypad.heightAnchor.constraint(equalToConstant: 400)
        ])
        
        bottomConstraint = keypad.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: 400)
        bottomConstraint.isActive = true
    }
    
    func showNumericKeypad() {
        bottomConstraint.constant = 0
        UIView.animate(withDuration: 0.25) {
            self.view.layoutIfNeeded()
        }
    }
    
    func keypadDidInput(_ input: NumericKeypadInput) {
        let value = engine.input(input)
        viewModel.handleNumericKeypad(value)
        
        let formatted = NSDecimalNumber(decimal: value).int64Value.formattedWithComma
        amountLabel.text = "\(formatted)"
    }
    
    func keypadDidHide() {
        bottomConstraint.constant = 400
        UIView.animate(withDuration: 0.25) {
            self.view.layoutIfNeeded()
        }
    }
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        if touch.view?.isDescendant(of: keypad) == true {
            return false
        }
        return true
    }
}

extension TransactionDetailViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        keypadDidHide()
    }
}
