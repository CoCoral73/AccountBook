//
//  PeriodSelectionViewController.swift
//  AccountBook
//
//  Created by 김정원 on 10/23/25.
//

import UIKit

class PeriodSelectionViewController: UIViewController {

    @IBOutlet weak var stackView: UIStackView!
    @IBOutlet weak var topConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var segControl: UISegmentedControl!
    @IBOutlet weak var startDateButton: UIButton!
    @IBOutlet weak var endDateButton: UIButton!
    @IBOutlet weak var borderView: UIView!
    @IBOutlet weak var datePicker: UIDatePicker!
    @IBOutlet weak var pickerView: UIPickerView!
    
    var viewModel: PeriodSelectionViewModel
    
    required init?(coder: NSCoder, viewModel: PeriodSelectionViewModel) {
        self.viewModel = viewModel
        super.init(coder: coder)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        viewModel.onDidChangedDatePicker = { [weak self] in
            guard let self = self else { return }
            startDateButton.setTitle(viewModel.startDateButtonString, for: .normal)
            endDateButton.setTitle(viewModel.endDateButtonString, for: .normal)
        }
        
        configurePickerView()
        bindViewModel()
    }
    
    func configurePickerView() {
        pickerView.delegate = self
        pickerView.dataSource = self
        
        pickerView.selectRow(viewModel.selectedRowForYear, inComponent: 0, animated: false)
        pickerView.selectRow(viewModel.selectedRowForMonth, inComponent: 1, animated: false)
    }
    
    func bindViewModel() {
        startDateButton.setTitle(viewModel.startDateButtonString, for: .normal)
        endDateButton.setTitle(viewModel.endDateButtonString, for: .normal)
        startDateButton.isEnabled = viewModel.dateButtonEnabled
        endDateButton.isEnabled = viewModel.dateButtonEnabled
        
        pickerView.isHidden = viewModel.isHiddenForPickerView
        datePicker.isHidden = viewModel.isHiddenForDatePicker
        
        pickerView.selectRow(viewModel.selectedRowForYear, inComponent: 0, animated: false)
        pickerView.selectRow(viewModel.selectedRowForMonth, inComponent: 1, animated: false)
    }
    
    @IBAction func segControlChanged(_ sender: UISegmentedControl) {
        viewModel.setPeriodType(sender.selectedSegmentIndex)
        bindViewModel()
    }
    
    @IBAction func dateButtonTapped(_ sender: UIButton) {
        viewModel.handleDateButton(sender.tag)
        startDateButton.isSelected = startDateButton.tag == sender.tag
        endDateButton.isSelected = endDateButton.tag == sender.tag
        print(startDateButton.isSelected, endDateButton.isSelected)
    }
    
    @IBAction func datePickerChanged(_ sender: UIDatePicker) {
        viewModel.handleDatePicker(sender.date)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        // 레이아웃 계산을 보장
        view.layoutIfNeeded()

        // 스택뷰의 실제 높이
        let stackViewHeight = stackView.systemLayoutSizeFitting(UIView.layoutFittingCompressedSize).height

        // 최종 preferredContentSize 반영
        preferredContentSize = CGSize(
            width: view.bounds.width,
            height: topConstraint.constant + stackViewHeight
        )
    }
}

extension PeriodSelectionViewController: UIPickerViewDelegate, UIPickerViewDataSource {
    
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
