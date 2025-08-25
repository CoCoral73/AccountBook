//
//  DetailTransactionViewController.swift
//  AccountBook
//
//  Created by 김정원 on 8/18/25.
//

import UIKit

class DetailTransactionViewController: UIViewController {
    
    
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

        configurePopGestrue()
    }
    
    private func configurePopGestrue() {
        navigationController?.interactivePopGestureRecognizer?.delegate = nil
        navigationController?.interactivePopGestureRecognizer?.isEnabled = true
    }

    @IBAction func backButtonTapped(_ sender: UIBarButtonItem) {
        navigationController?.popViewController(animated: true)
    }
    
    @IBAction func removeButtonTapped(_ sender: UIBarButtonItem) {
    }
    
}
