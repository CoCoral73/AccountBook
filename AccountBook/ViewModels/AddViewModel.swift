//
//  AddViewModel.swift
//  AccountBook
//
//  Created by 김정원 on 7/9/25.
//

import UIKit

class AddViewModel {
    
    private var currentDate: Date {
        didSet {
            onDidSetCurrentDate?()
        }
    }
    
    var onDidSetCurrentDate: (() -> Void)?
    
    init(currentDate: Date) {
        self.currentDate = currentDate
    }
    
    var currentDateString: String {
        let df = DateFormatter()
        df.dateFormat = "yyyy년 M월 d일"
        return df.string(from: currentDate)
    }
    
    func handleDateButton(storyboard: UIStoryboard?, fromVC: UIViewController) {
        let vm = DatePickerViewModel(initialDate: currentDate)
        vm.onDatePickerChanged = { [weak self] date in
            guard let self = self else { return }
            self.currentDate = date
        }
        
        guard let dateVC = storyboard?.instantiateViewController(identifier: "DatePickerViewController", creator: { coder in
            DatePickerViewController(coder: coder, viewModel: vm) })
        else {
            fatalError("DatePickerViewController 생성 에러")
        }
        
        if let sheet = dateVC.sheetPresentationController {
            sheet.detents = [.medium()]
        }
        fromVC.present(dateVC, animated: true, completion: nil)
    }
}
