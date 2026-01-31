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
    case duplicatedName
    
    var message: String {
        switch self {
        case .emptyIcon:
            "아이콘을 입력해주세요"
        case .emptyName:
            "이름을 입력해주세요"
        case .duplicatedName:
            "이미 존재하는 카테고리 이름입니다."
        }
    }
}

class CategoryEditViewModel {
    var mode: CategoryEditMode
    var type: TransactionType
    var onDidEditCategory: (() -> ())?
    
    init(type: TransactionType, mode: CategoryEditMode) {
        self.type = type
        self.mode = mode
    }
    
    var title: String {
        return "\(type.name) 카테고리 \(mode.name)"
    }
    
    var iconName: String {
        switch mode {
        case .add:
            "☺️"
        case .edit(let category):
            category.iconName
        }
    }
    
    var categoryName: String {
        switch mode {
        case .add:
            ""
        case .edit(let category):
            category.name
        }
    }
    
    var isRemoveButtonHidden: Bool { mode == .add }
    
    func validateInput(icon: String?, name: String?) -> CategoryInputError? {
        guard let icon = icon, !icon.isEmpty else { return .emptyIcon }
        guard let name = name, !name.isEmpty else { return .emptyName }
        guard !CategoryManager.shared.checkDuplicate(type: type, name: name) else { return .duplicatedName }
        return nil
    }
    
    func handleDoneButton(icon: String, name: String) {
        switch mode {
        case .add:
            CategoryManager.shared.addCategory(icon: icon, name: name, type: type)
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
            CategoryManager.shared.removeCategory(category)
            onDidEditCategory?()
        }
    }
}
