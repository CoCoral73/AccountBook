//
//  CategoryEditViewModel.swift
//  AccountBook
//
//  Created by 김정원 on 9/17/25.
//

enum CategoryEditMode: Equatable {
    case add
    case edit(Category)
    
    var name: String {
        switch self {
        case .add:
            return "추가"
        case .edit:
            return "수정"
        }
    }
}

enum CategoryInputError {
    case emptyIcon
    case emptyName
    
    var message: String {
        switch self {
        case .emptyIcon:
            "아이콘을 입력해주세요"
        case .emptyName:
            "이름을 입력해주세요"
        }
    }
}

class CategoryEditViewModel {
    var mode: CategoryEditMode
    var isIncome: Bool
    var onDidEditCategory: (() -> ())?
    
    init(isIncome: Bool, mode: CategoryEditMode) {
        self.isIncome = isIncome
        self.mode = mode
    }
    
    var title: String {
        let income = isIncome ? "수입" : "지출"
        let mode = (mode == .add) ? "추가" : "수정"
        return "\(income) 카테고리 \(mode)"
    }
    
    var textForIcon: String {
        switch mode {
        case .add:
            "☺️"
        case .edit(let category):
            category.iconName
        }
    }
    
    var nameString: String {
        switch mode {
        case .add:
            ""
        case .edit(let category):
            category.name
        }
    }
    
    var isHiddenForRemoveButton: Bool { mode == .add }
    
    func validateInput(icon: String?, name: String?) -> CategoryInputError? {
        guard let icon = icon, !icon.isEmpty else { return .emptyIcon }
        guard let name = name, !name.isEmpty else { return .emptyName }
        return nil
    }
    
    func handleDoneButton(icon: String, name: String) {
        switch mode {
        case .add:
            CategoryManager.shared.addCategory(icon: icon, name: name, isIncome: isIncome)
        case .edit(let category):
            CategoryManager.shared.updateCategory(with: category, icon: icon, name: name)
        }
        
        onDidEditCategory?()
    }
    
    func handleRemoveButton() {
        switch mode {
        case .add:
            return
        case .edit(let category):
            CategoryManager.shared.deleteCategory(category)
            onDidEditCategory?()
        }
    }
}
