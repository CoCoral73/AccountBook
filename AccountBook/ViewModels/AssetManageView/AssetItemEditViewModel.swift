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
    private(set) var colorIndex: Int = 0
    private var balance: Int64 = 0
    private var linkedAccount: BankAccountItem?
    private var withdrawalDay: Int16 = 13
    private var startDay: Int16 = 1
    
    //거래 추가 안에서 자산 추가했을 때
    var onDidAddAssetItem: (() -> Void)?
    //자산 상세 -> 편집에서 수정했을 때
    var onDidUpdateAssetItem: (() -> Void)?
    //편집모드에서 삭제했을 때
    var onDidRemoveAsset: (() -> Void)?

    init(type: AssetType = .bankAccount) {
        self.type = type
        self.mode = .add
    }
    
    init(asset: AssetItem) {
        self.mode = .edit(asset)
        self.type = asset.type
        
        self.name = asset.name
        self.colorIndex = asset.colorIndex
        switch asset {
        case let cash as CashItem:
            self.balance = cash.balance
        case let bank as BankAccountItem:
            self.balance = bank.balance
        case let debit as DebitCardItem:
            self.linkedAccount = debit.linkedAccount
        case let credit as CreditCardItem:
            self.linkedAccount = credit.linkedAccount
            self.withdrawalDay = credit.withdrawalDay
            self.startDay = credit.startDay
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
    var isHiddenForRemoveButton: Bool { mode == .add || type == .cash }
    var nameTextFieldText: String { name }
    var balanceLabelText: String { balance.formattedWithComma + "원" }
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
    var periodString: String { CardManager.shared.getPeriodString(withdrawalDay: withdrawalDay, startDay: startDay) }
    var withdrawalDayString: String { "당월 \(withdrawalDay)일 출금" }
    
    func setType(with index: Int) { //0: 계좌, 1: 체크카드, 2: 신용카드
        let type = AssetType(rawValue: Int16(index) + 1)!
        self.type = type
    }
    func setColorIndex(with index: Int) {
        self.colorIndex = index
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
    
    func handleNumericKeypad(_ value: Decimal) {
        balance = NSDecimalNumber(decimal: value).int64Value
    }
    
    func handleDoneButton(name: String) {
        self.name = name
        
        switch mode {
        case .add:
            addAssetItem()
        case .edit(let asset):
            editAssetItem(with: asset)
            onDidUpdateAssetItem?()
        }
    }
    
    func addAssetItem() {
        switch type {
        case .bankAccount:
            AssetItemManager.shared.addBankAccount(name: name, colorIndex: colorIndex, balance: balance)
        case .debitCard:
            AssetItemManager.shared.addDebitCard(name: name, colorIndex: colorIndex, account: linkedAccount)
        case .creditCard:
            AssetItemManager.shared.addCreditCard(name: name, colorIndex: colorIndex, account: linkedAccount, withdrawalDate: withdrawalDay, startDate: startDay)
        default:
            break
        }
        
        onDidAddAssetItem?()
    }
    
    func editAssetItem(with asset: AssetItem) {
        switch type {
        case .cash:
            AssetItemManager.shared.updateAssetItem(with: asset, name: name, colorIndex: colorIndex, balance: balance)
        case .bankAccount:
            AssetItemManager.shared.updateAssetItem(with: asset, name: name, colorIndex: colorIndex, balance: balance)
        case .debitCard:
            AssetItemManager.shared.updateAssetItem(with: asset, name: name, colorIndex: colorIndex, account: linkedAccount)
        case .creditCard:
            AssetItemManager.shared.updateAssetItem(with: asset, name: name, colorIndex: colorIndex, account: linkedAccount, withdrawalDate: withdrawalDay, startDate: startDay)
        default:
            break
        }
    }
    
    func handleRemoveButton() {
        guard case let .edit(asset) = mode else {
            print("삭제할 자산 없음")
            return 
        }
        onDidRemoveAsset?()
        AssetItemManager.shared.deleteAssetItem(with: asset)
    }
}
