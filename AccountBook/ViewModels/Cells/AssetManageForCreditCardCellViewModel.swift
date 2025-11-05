//
//  AssetManageForCreditCardCellViewModel.swift
//  AccountBook
//
//  Created by 김정원 on 11/5/25.
//

class AssetManageForCreditCardCellViewModel {
    
    var asset: CreditCardItem!
    
    init(asset: CreditCardItem!) {
        self.asset = asset
    }
    
    var nameString: String { asset.name }    
    //로직 필요
    var currentMonthSpendingString: String {
        return "이번달 사용금액 원"
    }
    var upcomingPaymentAmountString: String {
        return "결제 예정금액 원"
    }
}
