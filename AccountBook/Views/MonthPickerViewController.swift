//
//  MonthPickerViewController.swift
//  AccountBook
//
//  Created by 김정원 on 7/6/25.
//

import UIKit

class MonthPickerViewController: UIViewController {

    @IBOutlet weak var cancelButton: UIBarButtonItem!
    @IBOutlet weak var todayButton: UIBarButtonItem!
    @IBOutlet weak var selectButton: UIBarButtonItem!
    
    @IBOutlet weak var pickerView: UIPickerView!

    var viewModel: MonthPickerViewModel
    
    required init?(coder: NSCoder, viewModel: MonthPickerViewModel) {
        self.viewModel = viewModel
        super.init(coder: coder)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        initPickerView()
    }

    @IBAction func cancelButtonTapped(_ sender: UIBarButtonItem) {
        dismiss(animated: true)
    }
    @IBAction func todayButtonTapped(_ sender: UIBarButtonItem) {
        viewModel.handleTodayButton()
        pickerView.selectRow(viewModel.selectedYearIndex, inComponent: 0, animated: true)
        pickerView.selectRow(viewModel.selectedMonthIndex, inComponent: 1, animated: true)
    }
    @IBAction func selectButtonTapped(_ sender: UIBarButtonItem) {
        viewModel.handleSelectButton(year: pickerView.selectedRow(inComponent: 0), month: pickerView.selectedRow(inComponent: 1))
        dismiss(animated: true)
    }
    

}

extension MonthPickerViewController: UIPickerViewDelegate, UIPickerViewDataSource {
    
    func initPickerView() {
        pickerView.delegate = self
        pickerView.dataSource = self
        
        pickerView.selectRow(viewModel.selectedYearIndex, inComponent: 0, animated: false)
        pickerView.selectRow(viewModel.selectedMonthIndex, inComponent: 1, animated: false)
    }
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return component == 0 ? viewModel.years.count : viewModel.months.count
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 2
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return component == 0 ? "\(viewModel.years[row])년" : "\(viewModel.months[row])월"
    }
    
}
