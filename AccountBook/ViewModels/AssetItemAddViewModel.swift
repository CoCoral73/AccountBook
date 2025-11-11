//
//  AddAssetItemViewModel.swift
//  AccountBook
//
//  Created by 김정원 on 8/14/25.
//

import UIKit

class AssetItemAddViewModel {
    
    private var asset: AssetItem?
    private var type: AssetType
    private var name: String = ""
    private var balance: Int64 = 0
    private var linkedAccount: BankAccountItem?
    private var withdrawalDay: Int16 = 1
    private var startDay: Int16 = 1
    
    private var isModifyMode: Bool
    
    //거래 추가 안에서 자산 추가했을 때
    var onDidAddAssetItem: (() -> Void)?
    
    init(type: AssetType) {
        self.type = type
        self.isModifyMode = false
    }
    
    init(asset: AssetItem) {
        self.asset = asset
        self.type = AssetType(rawValue: Int(asset.type))!
        self.isModifyMode = true
        
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
    
    var title: String { isModifyMode ? "자산 수정" : "자산 추가" }
    var isHiddenForSegControl: Bool { isModifyMode }
    var topConstraintConstant: CGFloat {
        isModifyMode ? 40 : 91
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
    var isHiddenForCard: Bool { type == .cash || type == .bankAccount }
    var isHiddenForCredit: Bool { type != .creditCard }
    var nameTextFieldString: String { name }
    var balanceTextFieldString: String { String(balance) }
    var accountButtonTitleString: String { linkedAccount?.name ?? "선택 안함" }
    var selectWithdrawlDateButtonTitle: String { "\(withdrawalDay)일" }
    var selectStartDateButtonTitle: String { "\(startDay)일" }
    
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
    
    func handleDayButton(tag: Int, storyboard: UIStoryboard?, fromVC: AssetItemAddViewController) {
        let pickerVC = storyboard?.instantiateViewController(withIdentifier: "DayPickerViewController") as! DayPickerViewController
        pickerVC.titleString = tag == 0 ? "출금일" : "시작일"
        pickerVC.onDidSelectDay = { [weak self] (title, day) in
            guard let self = self else { return }
            
            if title == "출금일" {
                setWithdrawalDay(with: day)
                fromVC.withdrawalDayButton.setTitle(selectWithdrawlDateButtonTitle, for: .normal)
            } else if title == "시작일" {
                setStartDay(with: day)
                fromVC.startDayButton.setTitle(selectStartDateButtonTitle, for: .normal)
            }
        }
        
        if let sheet = pickerVC.sheetPresentationController {
            sheet.detents = [.custom { _ in
                return pickerVC.preferredContentSize.height
            }]
            sheet.prefersScrollingExpandsWhenScrolledToEdge = true
        }
        
        fromVC.present(pickerVC, animated: true)
    }
    
    func handleDoneButton() {
        isModifyMode ? modifyAssetItem() : addAssetItem()
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
    
    func modifyAssetItem() {
        guard let asset = asset else {
            print("수정할 자산 없음")
            return
        }
        
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
}
