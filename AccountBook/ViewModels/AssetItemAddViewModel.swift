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
