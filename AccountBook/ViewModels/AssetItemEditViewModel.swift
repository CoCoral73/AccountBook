//
//  AssetItemEditViewModel.swift
//  AccountBook
//
//  Created by 김정원 on 8/14/25.
//

import Foundation

enum AssetEditMode: Equatable {
    case add
    case edit(AssetItem)
}

class AssetItemEditViewModel {
    
    var mode: AssetEditMode
    private var type: AssetType
    private var name: String = ""
    private var balance: Int64 = 0
    private var linkedAccount: BankAccountItem?
    private var withdrawalDay: Int16 = 1
    private var startDay: Int16 = 1
    
    //거래 추가 안에서 자산 추가했을 때
    var onDidAddAssetItem: (() -> Void)?

    init(type: AssetType = .bankAccount) {
        self.type = type
        self.mode = .add
    }
    
    init(asset: AssetItem) {
        self.mode = .edit(asset)
        self.type = AssetType(rawValue: Int(asset.type))!
        
        self.name = asset.name
        switch asset {
        case let cash as CashItem:
            self.balance = cash.balance
        case let bank as BankAccountItem:
            self.balance = bank.balance
        case let debit as DebitCardItem:
            self.linkedAccount = debit.linkedAccount
        case let credit as CreditCardItem:
            self.linkedAccount = credit.linkedAccount
            self.withdrawalDay = credit.withdrawalDate
            self.startDay = credit.startDate
        default: break
        }
    }
    
    var title: String { mode == .add ? "자산 추가" : "자산 수정" }
    var isHiddenForSegControl: Bool { mode != .add }    //수정 모드일 때는 숨김
    var topConstraintConstant: CGFloat {
        mode != .add ? 40 : 91
    }
    var selectedSegmentIndex: Int {
        switch self.type {
        case .bankAccount: return 0
        case .debitCard: return 1
        case .creditCard: return 2
        default: return -1
        }
    }
    var isEnabledForNameTextField: Bool { type != .cash }
    var isHiddenForAccount: Bool { type == .debitCard || type == .creditCard }
    var isHiddenForTableView: Bool { !(mode != .add && type == .bankAccount && numberOfRowsInSection > 0) }
    var isHiddenForCard: Bool { type == .cash || type == .bankAccount }
    var isHiddenForCredit: Bool { type != .creditCard }
    var isHiddenForRemoveButton: Bool { mode == .add }
    var nameTextFieldString: String { name }
    var balanceTextFieldString: String { String(balance) }
    var numberOfRowsInSection: Int { cellForRowAt.count }
    var cellForRowAt: [AssetItem] {
        guard case let .edit(asset) = mode, let bank = asset as? BankAccountItem else { return [] }
        let debits = Array(bank.linkedDebitCards as? Set<AssetItem> ?? [])
        let credits = Array(bank.linkedCreditCards as? Set<AssetItem> ?? [])
        return debits + credits
    }
    var accountButtonTitleString: String { linkedAccount?.name ?? "선택 안함" }
    var selectWithdrawlDateButtonTitle: String { "\(withdrawalDay)일" }
    var selectStartDateButtonTitle: String { "\(startDay)일" }
    
    func setType(with index: Int) { //0: 계좌, 1: 체크카드, 2: 신용카드
        let type = AssetType(rawValue: index + 1)!
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
    
    func handleDoneButton() {
        switch mode {
        case .add:
            addAssetItem()
        case .edit(let asset):
            editAssetItem(with: asset)
        }
    }
    
    func addAssetItem() {
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
    
    func editAssetItem(with asset: AssetItem) {
        switch type {
        case .cash:
            AssetItemManager.shared.updateAssetItem(with: asset, name: name, balance: balance)
        case .bankAccount:
            AssetItemManager.shared.updateAssetItem(with: asset, name: name, balance: balance)
        case .debitCard:
            AssetItemManager.shared.updateAssetItem(with: asset, name: name, account: linkedAccount)
        case .creditCard:
            AssetItemManager.shared.updateAssetItem(with: asset, name: name, account: linkedAccount, withdrawalDate: withdrawalDay, startDate: startDay)
        }
    }
    
    func handleRemoveButton() {
        guard case let .edit(asset) = mode else {
            print("삭제할 자산 없음")
            return 
        }
        AssetItemManager.shared.deleteAssetItem(with: asset)
    }
}
