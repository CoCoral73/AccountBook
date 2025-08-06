//
//  AssetItemManager.swift
//  AccountBook
//
//  Created by 김정원 on 8/6/25.
//

import Foundation

class AssetItemManager {
    static let shared = AssetItemManager()
    private init() { }
    
    private var assetItems: [AssetItem] = []
    private(set) var bankAccount: [AssetItem] = []
    private(set) var debitCard: [AssetItem] = []
    private(set) var creditCard: [AssetItem] = []
    
    func loadAssetItems() {
        assetItems = CoreDataManager.shared.fetchAssetItems()
        
        for item in assetItems {
            switch item.typeRawValue {
            case 1: bankAccount.append(item)
            case 2: debitCard.append(item)
            case 3: creditCard.append(item)
            default: break
            }
        }
    }
    
    func addAssetItem(with item: AssetItem) {
        switch item.typeRawValue {
        case 1: bankAccount.append(item)
        case 2: debitCard.append(item)
        case 3: creditCard.append(item)
        default: break
        }
        CoreDataManager.shared.saveContext()
    }
    
    func removeAssetItem(with item: AssetItem) {
        switch item.typeRawValue {
        case 1:
            if let index = bankAccount.firstIndex(of: item) {
                bankAccount.remove(at: index)
            }
        case 2:
            if let index = debitCard.firstIndex(of: item) {
                debitCard.remove(at: index)
            }
        case 3:
            if let index = creditCard.firstIndex(of: item) {
                creditCard.remove(at: index)
            }
        default: break
        }
        CoreDataManager.shared.context.delete(item)
        CoreDataManager.shared.saveContext()
    }
}
