//
//  DatePickerViewController.swift
//  AccountBook
//
//  Created by 김정원 on 7/15/25.
//

import UIKit

class DatePickerViewController: UIViewController {
    
    @IBOutlet weak var datePicker: UIDatePicker!
    
    var viewModel: DatePickerViewModel
    
    required init?(coder: NSCoder, viewModel: DatePickerViewModel) {
        self.viewModel = viewModel
        super.init(coder: coder)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        datePicker.date = viewModel.currentDate
    }
    
    @IBAction func datePickerChanged(_ sender: UIDatePicker) {
        viewModel.onDatePickerChanged?(sender.date)
        dismiss(animated: true)
    }
    
}
