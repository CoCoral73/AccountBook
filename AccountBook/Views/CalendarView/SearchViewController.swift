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
    }
    
    func configureNavigationBar() {
        let appearance = UINavigationBarAppearance()
        appearance.configureWithTransparentBackground()
        navItem.standardAppearance = appearance
    }
    
    func configureTextField() {
        searchTextField.addTarget(self, action: #selector(didChangedTextField), for: .editingChanged)
    }
    
    @objc func didChangedTextField() {
        
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
    }
    
    @IBAction func assetButtonTapped(_ sender: UIButton) {
    }
    
    @IBAction func minAmountButtonTapped(_ sender: UIButton) {
    }
    
    @IBAction func maxAmountButtonTapped(_ sender: UIButton) {
    }
    
    @IBAction func sortButtonTapped(_ sender: UIButton) {
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        applyInitialTheme()
    }
    
}
