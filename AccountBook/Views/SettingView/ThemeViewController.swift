//
//  ThemeViewController.swift
//  AccountBook
//
//  Created by 김정원 on 11/25/25.
//

import UIKit

class ThemeViewController: UIViewController, ThemeApplicable {

    @IBOutlet weak var navItem: UINavigationItem!
    @IBOutlet weak var backButton: UIBarButtonItem!
    @IBOutlet weak var tableView: UITableView!
    
    var viewModel = ThemeViewModel()
    var flag = false
    
    override func viewDidLoad() {
        super.viewDidLoad()

        startObservingTheme()
        configureNavigationBar()
        configureTableView()
        
        applyTheme(ThemeManager.shared.currentTheme)
    }
    
    func applyTheme(_ theme: any AppTheme) {
        backButton.tintColor = theme.accentColor
    }
    
    func configureNavigationBar() {
        let appearance = UINavigationBarAppearance()
        appearance.configureWithTransparentBackground()
        navItem.standardAppearance = appearance
    }

    func configureTableView() {
        tableView.dataSource = self
        tableView.delegate = self
    }
    
    @IBAction func backButtonTapped(_ sender: UIBarButtonItem) {
        navigationController?.popViewController(animated: true)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        if flag { return }
        
        let indexPath = IndexPath(row: viewModel.selectedRow, section: 0)
        tableView.selectRow(at: indexPath, animated: false, scrollPosition: .none)
        flag = true
    }
    
    deinit {
        stopObservingTheme()
    }
}

extension ThemeViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.numberOfRowsInSection
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: Cell.themeCell, for: indexPath) as! ThemeTableViewCell
        cell.model = viewModel.cellForRowAt(row: indexPath.row)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        viewModel.didSelectRowAt(row: indexPath.row)
    }
}
