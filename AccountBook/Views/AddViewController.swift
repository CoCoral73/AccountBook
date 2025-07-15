//
//  AddViewController.swift
//  AccountBook
//
//  Created by 김정원 on 7/9/25.
//

import UIKit

class AddViewController: UIViewController {
    
    @IBOutlet weak var dateButton: UIBarButtonItem!
    
    var viewModel: AddViewModel
    
    required init?(coder: NSCoder, viewModel: AddViewModel) {
        self.viewModel = viewModel
        super.init(coder: coder)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        viewModel.onDidSetCurrentDate = { [weak self] in
            guard let self = self else { return }
            self.dateButton.title = self.viewModel.currentDateString
        }
        dateButton.title = self.viewModel.currentDateString
    }
    
    @IBAction func closeButtonTapped(_ sender: UIBarButtonItem) {
        dismiss(animated: true)
    }
    
    @IBAction func dateButtonTapped(_ sender: UIBarButtonItem) {
        viewModel.handleDateButton(storyboard: storyboard, fromVC: self)
    }
    
}
