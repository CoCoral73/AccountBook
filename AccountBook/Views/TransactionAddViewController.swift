//
//  AddViewController.swift
//  AccountBook
//
//  Created by 김정원 on 7/9/25.
//

import UIKit

class TransactionAddViewController: UIViewController {
    
    @IBOutlet weak var dateButton: UIBarButtonItem!
    
    @IBOutlet weak var containerViewForCategory: UIView!
    
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
        let vm = viewModel.handleDateButton()
        
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
            viewModel.inputVC = tableVC
        }
    }
}
