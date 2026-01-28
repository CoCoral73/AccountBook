//
//  AssetSelectionViewModel.swift
//  AccountBook
//
//  Created by 김정원 on 11/21/25.
//

class AssetSelectionViewModel {
    var type: TransactionType
    
    init(type: TransactionType) {
        self.type = type
    }
    
    var onAssetSelected: ((AssetItem) -> ())?
    
    var assetTypes: [AssetType] {
        switch type {
        case .income:
            return [.cash, .bankAccount]
        case .expense:
            return [.cash, .bankAccount, .debitCard, .creditCard]
        case .transfer:
            return [.bankAccount]
        }
    }
    
    func didSelectRowAt(with item: AssetItem) {
        onAssetSelected?(item)
    }
}
