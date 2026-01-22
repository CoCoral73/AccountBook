//
//  SearchViewController.swift
//  AccountBook
//
//  Created by 김정원 on 1/12/26.
//

import UIKit

class SearchViewController: UIViewController, ThemeApplicable {

    @IBOutlet weak var navItem: UINavigationItem!
    @IBOutlet weak var backButton: UIBarButtonItem!
    @IBOutlet weak var searchBar: UIView!
    @IBOutlet weak var searchImageButton: UIButton!
    @IBOutlet weak var searchTextField: UITextField!
    @IBOutlet weak var periodButton: UIButton!
    @IBOutlet weak var periodSelectButton: UIButton!
    @IBOutlet weak var categoryButton: UIButton!
    @IBOutlet weak var assetButton: UIButton!
    @IBOutlet weak var minAmountButton: UIButton!
    @IBOutlet weak var maxAmountButton: UIButton!
    @IBOutlet weak var sortButton: UIButton!
    @IBOutlet weak var tableView: IntrinsicTableView!
    
    @IBOutlet weak var overlayView: UIView!
    @IBOutlet weak var popUpView: UIView!
    @IBOutlet weak var popUpViewTitle: UILabel!
    @IBOutlet weak var filterTableView: UITableView!
    @IBOutlet weak var topConstraint: NSLayoutConstraint!
    @IBOutlet weak var bottomConstraint: NSLayoutConstraint!
    
    private var amountButtons: [UIButton] = []
    
    private let engine = CalculatorEngine()
    private let keypad = NumericKeypadView.loadFromNib()
    private var keypadBottomConstraint: NSLayoutConstraint!
    
    private var currentAmountButtonTag: Int = 0
    
    var viewModel: SearchViewModel
    
    required init?(coder: NSCoder, viewModel: SearchViewModel) {
        self.viewModel = viewModel
        super.init(coder: coder)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        bindViewModel()
        configureNavigationBar()
        configureTextField()
        configureTapGesture()
        configureKeypadLayout()
        amountButtons = [minAmountButton, maxAmountButton]
        configureTableView()
    }

    func applyTheme(_ theme: any AppTheme) {
        backButton.tintColor = theme.accentColor
        searchBar.borderColor = theme.accentColor
        searchBar.backgroundColor = theme.baseColor
        searchImageButton.tintColor = theme.accentColor
    }
    
    func bindViewModel() {
        viewModel.onDidSetPeriod = { [weak self] in
            guard let self = self else { return }
            periodButton.setTitle(viewModel.periodTypeDisplay, for: .normal)
            periodSelectButton.isHidden = viewModel.isPeriodSelectButtonHidden
            periodSelectButton.setTitle(viewModel.periodDisplay, for: .normal)
        }
        
        viewModel.onRequestPopUp = { [weak self] in
            guard let self = self else { return }
            popUpViewTitle.text = viewModel.popUpViewTitle
            filterTableView.reloadData()
            showPopUp()
        }
    }
    
    func configureNavigationBar() {
        let appearance = UINavigationBarAppearance()
        appearance.configureWithTransparentBackground()
        navItem.standardAppearance = appearance
    }
    
    func configureTextField() {
        searchTextField.addTarget(self, action: #selector(didChangedTextField), for: .editingChanged)
    }
    
    func configureTapGesture() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(didTapOverlayView))
        overlayView.addGestureRecognizer(tap)
    }
    
    @objc func didTapOverlayView() {
        hidePopUp()
    }
    
    @objc func didChangedTextField(_ textField: UITextField) {
        viewModel.setKeyword(with: textField.text)
    }
    
    @IBAction func backButtonTapped(_ sender: UIBarButtonItem) {
        navigationController?.popViewController(animated: true)
    }
    
    @IBAction func searchImageButtonTapped(_ sender: UIButton) {
        searchTextField.becomeFirstResponder()
    }
    
    @IBAction func periodButtonTapped(_ sender: UIButton) {
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        let action1 = UIAlertAction(title: "전체", style: .default) { [weak self] _ in
            guard let self = self else { return }
            viewModel.handlePeriodButton(isEntire: true)
        }
        let action2 = UIAlertAction(title: "지정", style: .default) { [weak self] _ in
            guard let self = self else { return }
            viewModel.handlePeriodButton(isEntire: false)
        }
        
        alert.addAction(action1)
        alert.addAction(action2)
        alert.addAction(UIAlertAction(title: "취소", style: .cancel))
        
        present(alert, animated: true)
    }
    
    @IBAction func periodSelectButtonTapped(_ sender: UIButton) {
        let vm = viewModel.handlePeriodSelectButton()
        guard let vc = storyboard?.instantiateViewController(identifier: "PeriodSelectionViewController", creator: { coder in
            PeriodSelectionViewController(coder: coder, viewModel: vm)
        }) else {
            print("SearchViewController: PeriodSelection VC 생성 오류")
            return
        }
        
        if let sheet = vc.sheetPresentationController {
            sheet.detents = [.custom { _ in
                return vc.preferredContentSize.height
            }]
            sheet.prefersGrabberVisible = true
        }

        self.present(vc, animated: true, completion: nil)
    }
    
    @IBAction func categoryButtonTapped(_ sender: UIButton) {
        viewModel.handleCategoryButton()
    }
    
    @IBAction func assetButtonTapped(_ sender: UIButton) {
        viewModel.handleAssetButtonTapped()
    }
    
    func showPopUp() {
        overlayView.isHidden = false
        popUpView.isHidden = false
        self.topConstraint.constant = 50
        self.bottomConstraint.constant = 50
        
        UIView.animate(withDuration: 0.3) {
            self.view.layoutIfNeeded()
        }
    }
    
    func hidePopUp() {
        overlayView.isHidden = true
        self.topConstraint.constant = 1000
        self.bottomConstraint.constant = -900
        UIView.animate(withDuration: 0.3) {
            self.view.layoutIfNeeded()
        } completion: { _ in
            self.popUpView.isHidden = true
        }
    }
    
    @IBAction func cancelButtonTapped(_ sender: UIButton) {
        hidePopUp()
    }
    
    @IBAction func applyButtonTapped(_ sender: UIButton) {
        hidePopUp()
    }
    
    @IBAction func amountButtonTapped(_ sender: UIButton) {
        currentAmountButtonTag = sender.tag
        engine.setBuffer(viewModel.currentAmount(tag: sender.tag))
        showNumericKeypad()
    }
    
    @IBAction func sortButtonTapped(_ sender: UIButton) {
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        applyInitialTheme()
    }
    
}

extension SearchViewController: UITableViewDataSource, UITableViewDelegate {
    func configureTableView() {
        tableView.dataSource = self
        tableView.delegate = self
        
        tableView.rowHeight = 50
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.numberOfRowsInSection
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: Cell.searchCell, for: indexPath) as! SearchTableViewCell
        
        cell.viewModel = viewModel.cellForRowAt(indexPath.row)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let vm = viewModel.didSelectRowAt(indexPath.row)
        showTransactionDetailView(vm)
    }
    
    func showTransactionDetailView(_ vm: TransactionDetailViewModel) {
        guard let vc = storyboard?.instantiateViewController(identifier: "TransactionDetailViewController", creator: { coder in
            TransactionDetailViewController(coder: coder, viewModel: vm)
        }) else {
            print("SearchViewController: Transaction Detail VC 생성 오류")
            return
        }
        
        navigationController?.pushViewController(vc, animated: true)
    }
}

extension SearchViewController: NumericKeypadDelegate {
    func configureKeypadLayout() {
        keypad.delegate = self
        
        view.addSubview(keypad)
        keypad.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            keypad.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            keypad.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            keypad.heightAnchor.constraint(equalToConstant: 400)
        ])
        
        keypadBottomConstraint = keypad.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: 400)
        keypadBottomConstraint.isActive = true
    }
    
    func showNumericKeypad() {
        keypadBottomConstraint.constant = 0
        UIView.animate(withDuration: 0.25) {
            self.view.layoutIfNeeded()
        }
    }
    
    func keypadDidInput(_ input: NumericKeypadInput) {
        let value = engine.input(input)
        viewModel.handleNumericKeypad(value, tag: currentAmountButtonTag)
        
        let button = amountButtons[currentAmountButtonTag]
        
        button.setTitle(viewModel.currentAmountDisplay(tag: currentAmountButtonTag), for: .normal)
        button.setTitleColor(value == 0 ? .placeholderText : .black, for: .normal)
    }
    
    func keypadDidHide() {
        keypadBottomConstraint.constant = 400
        UIView.animate(withDuration: 0.25) {
            self.view.layoutIfNeeded()
        }
    }
    
}
