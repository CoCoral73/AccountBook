//
//  CategoryAddViewController.swift
//  AccountBook
//
//  Created by 김정원 on 9/17/25.
//

import UIKit

class CategoryAddViewController: UIViewController {
    
    @IBOutlet weak var navItem: UINavigationItem!
    
    var viewModel: CategoryAddViewModel
    
    required init?(coder: NSCoder, viewModel: CategoryAddViewModel) {
        self.viewModel = viewModel
        super.init(coder: coder)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        configureViewModel()
    }
    
    func configureViewModel() {
        navItem.title = viewModel.title
    }
    
    @IBAction func closeButtonTapped(_ sender: UIBarButtonItem) {
        dismiss(animated: true)
    }
    
    @IBAction func addButtonTapped(_ sender: UIBarButtonItem) {
    }
    
}
