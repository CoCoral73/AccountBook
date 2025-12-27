//
//  AssetItemDetailViewModel.swift
//  AccountBook
//
//  Created by 김정원 on 12/27/25.
//

class AssetItemDetailViewModel {
    
    private var asset: AssetItem
    
    var onShowAssetItemEditView: ((AssetItemEditViewModel) -> Void)?
    
    init(asset: AssetItem) {
        self.asset = asset
    }
    
    var title: String {
        return asset.name
    }
    
    func handleEditButton() {
        let vm = AssetItemEditViewModel(asset: asset)
        onShowAssetItemEditView?(vm)
    }
}
