//
//  AddAssetItemViewModel.swift
//  AccountBook
//
//  Created by 김정원 on 8/14/25.
//

import Foundation

class AddAssetItemViewModel {
    
    private var type: AssetType
    private var name: String = ""
    private var balance: Int64 = 0
    private var linkedAccount: BankAccountItem?
    private var withdrawalDay: Int16 = 1
    private var startDay: Int16 = 1
    
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
    
    var selectWithdrawlDateButtonTitle: String {
        return "\(withdrawalDay)일"
    }
    
    var selectStartDateButtonTitle: String {
        return "\(startDay)일"
    }
    
    func setType(with type: AssetType) {
        self.type = type
    }
    func setName(with name: String) {
        self.name = name
    }
    func setBalance(with balance: Int64) {
        self.balance = balance
    }
    func setLinkedAccount(with account: BankAccountItem?) {
        self.linkedAccount = account
    }
    func setWithdrawalDay(with day: Int16) {
        self.withdrawalDay = day
    }
    func setStartDay(with day: Int16) {
        self.startDay = day
    }
    
    func handleAddButton() {
        if name == "" { return }    //자산 이름 필수
        
        switch type {
        case .bankAccount:
            AssetItemManager.shared.addBankAccount(name: name, balance: balance)
        case .debitCard:
            AssetItemManager.shared.addDebitCard(name: name, account: linkedAccount)
        case .creditCard:
            AssetItemManager.shared.addCreditCard(name: name, account: linkedAccount, withdrawalDate: withdrawalDay, startDate: startDay)
        default:
            break
        }
        
        onDidAddAssetItem?()
    }
}
