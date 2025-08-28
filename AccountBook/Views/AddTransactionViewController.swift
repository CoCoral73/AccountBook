//
//  AddViewController.swift
//  AccountBook
//
//  Created by 김정원 on 7/9/25.
//

import UIKit

class AddTransactionViewController: UIViewController {
    
    @IBOutlet weak var dateButton: UIBarButtonItem!
    
    @IBOutlet weak var containerViewForCategory: UIView!
    
    var viewModel: AddTransactionViewModel
    
    required init?(coder: NSCoder, viewModel: AddTransactionViewModel) {
        self.viewModel = viewModel
        super.init(coder: coder)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        configureViewModel()
        configureCategoryView()
    }
    
    private func configureViewModel() {
        viewModel.onDidSetTransactionDate = { [weak self] in
            guard let self = self else { return }
            self.dateButton.title = self.viewModel.transactionDateString
        }
        
        dateButton.title = self.viewModel.transactionDateString
    }
    
    private func configureCategoryView() {
        viewModel.handleCategoryView(storyboard: storyboard, fromVC: self)
    }
    
    @IBAction func closeButtonTapped(_ sender: UIBarButtonItem) {
        dismiss(animated: true)
    }
    
    @IBAction func dateButtonTapped(_ sender: UIBarButtonItem) {
        viewModel.handleDateButton(storyboard: storyboard, fromVC: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let tableVC = segue.destination as? InputTableViewController {
            tableVC.viewModel = self.viewModel
            viewModel.inputVC = tableVC
        }
    }
}
