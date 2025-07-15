//
//  DatePickerViewModel.swift
//  AccountBook
//
//  Created by 김정원 on 7/15/25.
//

import UIKit

class DatePickerViewModel {
    var currentDate: Date
    var onDatePickerChanged: ((Date) -> Void)?
    
    init(initialDate: Date) {
        self.currentDate = initialDate
    }
}
