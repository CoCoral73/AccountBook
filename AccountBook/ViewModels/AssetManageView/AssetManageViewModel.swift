//
//  AssetManageViewModel.swift
//  AccountBook
//
//  Created by 김정원 on 11/5/25.
//

import UIKit

class AssetManageViewModel {
    
    var assetTotalAmountString: String {
        return totalBalance.formattedWithComma + "원"
    }
    
    var totalBalance: Int64 {
        return AssetItemManager.shared.cash[0].balance + bankBalance
    }
    
    var bankBalance: Int64 {
        return AssetItemManager.shared.bankAccount.reduce(0) { $0 + $1.balance }
    }
    
    func numberOfRowsInSection(section: Int) -> Int {
        guard let type = AssetType(rawValue: section) else {
            print("AssetManageViewModel: AssetType 생성 오류")
            return 0
        }
        return AssetItemManager.shared.getAssetItems(with: type).count
    }
    
    func withIdentifier(section: Int) -> String {
        return section == 3 ? Cell.assetManageForCreditCardCell : Cell.assetManageForNotCreditCardCell
    }
    
    func cellForRowAt(indexPath: IndexPath) -> AssetItem {
        guard let type = AssetType(rawValue: indexPath.section) else {
            fatalError("AssetManageViewModel: AssetType 생성 오류")
        }
        
        return AssetItemManager.shared.getAssetItems(with: type)[indexPath.row]
    }
    
    func viewForHeaderInSection(section: Int) -> (name: String, amount: String) {
        guard let type = AssetType(rawValue: section) else {
            fatalError("AssetManageViewModel: AssetType 생성 오류")
        }
        
        let name = type.displayName
        if section == 1 {
            let amount = bankBalance.formattedWithComma + "원"
            return (name, amount)
        } else {
            return (name, "")
        }
    }
    
}
