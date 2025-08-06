//
//  AssetViewModel.swift
//  AccountBook
//
//  Created by 김정원 on 8/6/25.
//

import Foundation

class AssetViewModel {
    
    private(set) var assetItem: AssetItem
    
    init(assetItem: AssetItem) {
        self.assetItem = assetItem
    }
    
    var nameString: String {
        assetItem.name
    }
}
