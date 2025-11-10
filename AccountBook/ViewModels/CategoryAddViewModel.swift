//
//  CategoryAddViewModel.swift
//  AccountBook
//
//  Created by 김정원 on 9/17/25.
//

import UIKit

class CategoryAddViewModel {
    var isIncome: Bool
    var onDidAddCategory: (() -> ())?
    
    init(isIncome: Bool) {
        self.isIncome = isIncome
    }
    
    var title: String {
        return isIncome ? "수입 카테고리 추가" : "지출 카테고리 추가"
    }
    
    var textForIcon: String = "☺️"
    
    var iconImage: UIImage? {
        return textForIcon.toImage()
    }
    
    func handleAddButton(fromVC: UIViewController, icon: String, name: String) {
        guard icon != " ", !name.isEmpty else {
            fromVC.view.endEditing(true)
            HapticFeedback.notify(.error)
            ToastManager.shared.show(message: "아이콘과 이름을 입력해주세요.", in: fromVC.view)
            return
        }
        
        CategoryManager.shared.addCategory(icon: icon, name: name, isIncome: isIncome)
        onDidAddCategory?()
        fromVC.dismiss(animated: true)
    }
}
