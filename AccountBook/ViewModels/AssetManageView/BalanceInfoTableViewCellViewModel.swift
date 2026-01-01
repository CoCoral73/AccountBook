//
//  AssetManageForNotCreditCardCellViewModel.swift
//  AccountBook
//
//  Created by 김정원 on 11/5/25.
//

class BalanceInfoTableViewCellViewModel {
    
    var asset: AssetItem!
    
    init(asset: AssetItem) {
        self.asset = asset
    }
    
    var nameString: String { asset.name }
    var amountString: String {
        switch asset.type {
        case 0:
            let asset = asset as! CashItem
            return asset.balance.formattedWithComma + "원"
        case 1:
            let asset = asset as! BankAccountItem
            return asset.balance.formattedWithComma + "원"
        case 2:
            let asset = asset as! DebitCardItem
            return "연결 계좌: \(asset.linkedAccount?.name ?? "미지정")"
        default:
            return ""
        }
    }
}
