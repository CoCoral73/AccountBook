//
//  AssetSelectionViewModel.swift
//  AccountBook
//
//  Created by 김정원 on 11/21/25.
//

class AssetSelectionViewModel {
    var isIncome: Bool
    
    init(isIncome: Bool) {
        self.isIncome = isIncome
    }
    
    var onAssetSelected: ((AssetItem) -> ())?
    
    func didSelectRowAt(with item: AssetItem) {
        onAssetSelected?(item)
    }
}
