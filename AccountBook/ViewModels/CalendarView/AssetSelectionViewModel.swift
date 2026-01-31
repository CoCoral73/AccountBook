//
//  AssetSelectionViewModel.swift
//  AccountBook
//
//  Created by 김정원 on 11/21/25.
//

class AssetSelectionViewModel {
    private(set) var type: TransactionType
    private(set) var selectedType: AssetType?
    
    init(type: TransactionType) {
        self.type = type
        
        if type == .transfer {
            selectedType = .bankAccount
        }
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
    
    var assetItems: [AssetItem] {
        guard let selectedType = selectedType else { return [] }
        return AssetItemManager.shared.getAssetItems(with: selectedType)
    }
    
    var numberOfRowsInSection: Int {
        guard let selectedType = selectedType else { return 0 }
        return AssetItemManager.shared.getAssetItems(with: selectedType).count + (selectedType != .cash ? 1 : 0)
    }
    
    func setSelectedType(_ row: Int) {
        selectedType = assetTypes[row]
    }
    
    func didSelectRowAt(_ row: Int) -> AssetItemEditViewModel? {
        if assetItems.count <= row {
            return AssetItemEditViewModel(type: selectedType ?? .bankAccount)
        }
        
        let item = assetItems[row]
        onAssetSelected?(item)
        return nil
    }
}
