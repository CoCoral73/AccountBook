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
        let isIncome = viewModel.isIncome
        guard let childVC = storyboard?.instantiateViewController(identifier: "CategoryViewController", creator: { coder in
            CategoryViewController(coder: coder, isIncome: isIncome)
        }) else {
            fatalError("CategoryViewController 생성 에러")
        }
        
        childVC.onDidSelectCategory = { [weak self] category in
            guard let self = self else { return }
            viewModel.addTransaction(with: category)
            dismiss(animated: true)
        }
        
        //embed 세그웨이 역할
        self.addChild(childVC)
        childVC.view.frame = self.containerViewForCategory.bounds
        self.containerViewForCategory.addSubview(childVC.view)
        childVC.didMove(toParent: self)
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
        }
    }
}
