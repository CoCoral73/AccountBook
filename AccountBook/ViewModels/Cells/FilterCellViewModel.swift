//
//  FilterCellViewModel.swift
//  AccountBook
//
//  Created by 김정원 on 1/19/26.
//

enum FilterType: Equatable {
    case category(Category)
    case asset(AssetItem)
}

class FilterCellViewModel {
    var type: FilterType
    var isCheck: Bool
    
    init(type: FilterType, isCheck: Bool) {
        self.type = type
        self.isCheck = isCheck
    }
    
    var onDidTapCheckBox: (() -> Void)?
    
    var isIconViewHidden: Bool {
        switch type {
        case .category:
            return false
        case .asset:
            return true
        }
    }
    
    var iconName: String? {
        switch type {
        case .category(let category):
            return category.iconName
        case .asset:
            return nil
        }
    }
    
    var name: String {
        switch type {
        case .category(let category):
            return category.name
        case .asset(let asset):
            return asset.name
        }
    }
    
    var checkImageName: String {
        if isCheck {
            return "checkmark.square.fill"
        } else {
            return "square"
        }
    }
}
