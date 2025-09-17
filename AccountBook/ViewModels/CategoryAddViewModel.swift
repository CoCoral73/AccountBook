//
//  CategoryAddViewModel.swift
//  AccountBook
//
//  Created by 김정원 on 9/17/25.
//

import UIKit

class CategoryAddViewModel {
    var isIncome: Bool?
    
    init(isIncome: Bool? = nil) {
        self.isIncome = isIncome
    }
    
    var title: String {
        guard let isIncome = isIncome else { return "카테고리 추가" }
        return isIncome ? "수입 카테고리 추가" : "지출 카테고리 추가"
    }
}
