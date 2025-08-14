//
//  AddAssetItemViewModel.swift
//  AccountBook
//
//  Created by 김정원 on 8/14/25.
//

import Foundation

class AddAssetItemViewModel {
    var type: AssetType
    var linkedAccount: BankAccountItem?
    
    var name: String = ""
    var balance: Int64 = 0
    
    var onDidAddAssetItem: (() -> Void)?
    
    init(type: AssetType) {
        self.type = type
    }
    
    var selectedSegmentIndex: Int {
        switch self.type {
        case .bankAccount: return 0
        case .debitCard: return 1
        case .creditCard: return 2
        default: return -1
        }
    }
    
    func setType(with type: AssetType) {
        self.type = type
    }
    
    func handleAddButton() {
        if name == ""   //이름 없으면 추가 불가능
        {
            return
        }
        
        switch type {
        case .bankAccount:
            let newItem = BankAccountItem(context: CoreDataManager.shared.context)
            newItem.id = UUID()
            newItem.name = name
            newItem.balance = balance
            newItem.transactions = nil
            AssetItemManager.shared.addAssetItem(with: newItem)
        case .debitCard:
            break
        case .creditCard:
            break
        default:
            break
        }
        
        onDidAddAssetItem?()
    }
}
