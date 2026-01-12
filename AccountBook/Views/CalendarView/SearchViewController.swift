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

        startObservingTheme()
        configureNavigationBar()
        configureTextField()
    }

    func applyTheme(_ theme: any AppTheme) {
        backButton.tintColor = theme.accentColor
        searchBar.borderColor = theme.accentColor
        searchBar.backgroundColor = theme.baseColor
        searchImageButton.tintColor = theme.accentColor
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
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        applyInitialTheme()
    }
    
    deinit {
        stopObservingTheme()
    }
}
