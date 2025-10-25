//
//  PeriodSelectionViewController.swift
//  AccountBook
//
//  Created by 김정원 on 10/23/25.
//

import UIKit

class PeriodSelectionViewController: UIViewController {

    @IBOutlet weak var segControl: UISegmentedControl!
    @IBOutlet weak var startDateButton: UIButton!
    @IBOutlet weak var endDateButton: UIButton!
    @IBOutlet weak var borderView: UIView!
    @IBOutlet weak var datePicker: UIDatePicker!
    @IBOutlet weak var pickerView: UIPickerView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    @IBAction func segControlChanged(_ sender: UISegmentedControl) {
    }
    @IBAction func dateButtonTapped(_ sender: UIButton) {
    }
    @IBAction func datePickerChanged(_ sender: UIDatePicker) {
    }
}
