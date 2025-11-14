//
//  CategoryEditViewModel.swift
//  AccountBook
//
//  Created by 김정원 on 9/17/25.
//

enum CategoryEditMode {
    case add
    case edit(Category)
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
    var onDidAddCategory: (() -> ())?
    
    init(isIncome: Bool, mode: CategoryEditMode) {
        self.isIncome = isIncome
        self.mode = mode
    }
    
    var title: String {
        return isIncome ? "수입 카테고리" : "지출 카테고리"
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
    
    func validateInput(icon: String?, name: String?) -> CategoryInputError? {
        guard let icon = icon, !icon.isEmpty else { return .emptyIcon }
        guard let name = name, !name.isEmpty else { return .emptyName }
        return nil
    }
    
    func handleAddButton(icon: String, name: String) {
        CategoryManager.shared.addCategory(icon: icon, name: name, isIncome: isIncome)
        onDidAddCategory?()
    }
}
