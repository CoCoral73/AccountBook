//
//  AssetItemManager.swift
//  AccountBook
//
//  Created by 김정원 on 8/6/25.
//

import Foundation

enum AssetType: Int, CaseIterable {
    case cash = 0
    case bankAccount = 1
    case debitCard = 2
    case creditCard = 3

    var displayName: String {
        switch self {
        case .cash: return "현금"
        case .bankAccount: return "계좌"
        case .debitCard: return "체크카드"
        case .creditCard: return "신용카드"
        }
    }

    var iconName: String {
        switch self {
        case .cash: return "💵"
        case .bankAccount: return "🏦"
        case .debitCard: return "💳"
        case .creditCard: return "💳"
        }
    }
}

class AssetItemManager {
    static let shared = AssetItemManager()
    private init() { }
    
    private(set) var cash: [CashItem] = []
    private(set) var bankAccount: [BankAccountItem] = []
    private(set) var debitCard: [DebitCardItem] = []
    private(set) var creditCard: [CreditCardItem] = []
    
    func loadAssetItems() {
        cash.removeAll()
        bankAccount.removeAll()
        debitCard.removeAll()
        creditCard.removeAll()
        
        let assetItems = CoreDataManager.shared.fetchAssetItems()
        
        assetItems.forEach { item in
            switch item {
            case let c as CashItem:
                cash.append(c)
            case let b as BankAccountItem:
                bankAccount.append(b)
            case let d as DebitCardItem:
                debitCard.append(d)
            case let cr as CreditCardItem:
                creditCard.append(cr)
            default:
                break
            }
        }
    }
    
    func getAssetItems(with type: AssetType) -> [AssetItem] {
        switch type {
        case .cash: return cash
        case .bankAccount: return bankAccount
        case .debitCard: return debitCard
        case .creditCard: return creditCard
        }
    }
    
    private func createItem<T: AssetItem>(_ type: T.Type, configure: (T) -> Void) -> T {
        let newItem = T(context: CoreDataManager.shared.context)
        newItem.id = UUID()
        newItem.transactions = nil
        configure(newItem)
        CoreDataManager.shared.saveContext()
        print(newItem)
        return newItem
    }
    
    func addBankAccount(name: String, balance: Int64) {
        let newItem: BankAccountItem = createItem(BankAccountItem.self) { item in
            item.name = name
            item.balance = balance
            item.type = 1
        }
        bankAccount.append(newItem)
    }
    
    func addDebitCard(name: String, account: BankAccountItem?) {
        let newItem: DebitCardItem = createItem(DebitCardItem.self) { item in
            item.name = name
            item.linkedAccount = account
            item.type = 2
        }
        debitCard.append(newItem)
    }
    
    func addCreditCard(name: String, account: BankAccountItem?, withdrawalDate: Int16, startDate: Int16) {
        let newItem: CreditCardItem = createItem(CreditCardItem.self) { item in
            item.name = name
            item.linkedAccount = account
            item.withdrawalDate = withdrawalDate
            item.startDate = startDate
            item.type = 3
        }
        creditCard.append(newItem)
    }
    
    func deleteAssetItem<T: AssetItem>(with item: T) {
        switch item {
        case let b as BankAccountItem:
            if let index = bankAccount.firstIndex(of: b) {
                bankAccount.remove(at: index)
            }
        case let d as DebitCardItem:
            if let index = debitCard.firstIndex(of: d) {
                debitCard.remove(at: index)
            }
        case let cr as CreditCardItem:
            if let index = creditCard.firstIndex(of: cr) {
                creditCard.remove(at: index)
            }
        default: break
        }
        CoreDataManager.shared.context.delete(item)
        CoreDataManager.shared.saveContext()
    }
}
