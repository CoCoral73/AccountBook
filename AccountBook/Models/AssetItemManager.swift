//
//  AssetItemManager.swift
//  AccountBook
//
//  Created by 김정원 on 8/6/25.
//

import Foundation

enum AssetType: Int16, CaseIterable {
    case cash = 0
    case bankAccount = 1
    case debitCard = 2
    case creditCard = 3
    case deleted = 4

    var displayName: String {
        switch self {
        case .cash: return "현금"
        case .bankAccount: return "계좌"
        case .debitCard: return "체크카드"
        case .creditCard: return "신용카드"
        case .deleted: return "삭제된 자산"
        }
    }
}

class AssetItemManager {
    static let shared = AssetItemManager()
    private init() { }
    
    private(set) var assetItems: [AssetItem] = []
    private(set) var cash: [CashItem] = []
    private(set) var bankAccount: [BankAccountItem] = []
    private(set) var debitCard: [DebitCardItem] = []
    private(set) var creditCard: [CreditCardItem] = []
    private(set) var deletedItem: [DeletedItem] = []
    var allAssetItems: [[AssetItem]] {
        return [cash, bankAccount, debitCard, creditCard]
    }
    
    func loadAssetItems() {
        cash.removeAll()
        bankAccount.removeAll()
        debitCard.removeAll()
        creditCard.removeAll()
        
        assetItems = CoreDataManager.shared.fetchAssetItems()
        
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
            case let deleted as DeletedItem:
                deletedItem.append(deleted)
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
        default: return []
        }
    }
    
    private func createItem<T: AssetItem>(_ type: T.Type, configure: (T) -> Void) -> T {
        let newItem = T(context: CoreDataManager.shared.context)
        newItem.id = UUID()
        newItem.transactions = nil
        configure(newItem)
        
        CoreDataManager.shared.saveContext()
        return newItem
    }
    
    func addBankAccount(name: String, colorIndex: Int, balance: Int64) {
        let newItem: BankAccountItem = createItem(BankAccountItem.self) { item in
            item.name = name
            item.colorIndexValue = Int16(colorIndex)
            item.balance = balance
            item.typeValue = 1
        }
        bankAccount.append(newItem)
    }
    
    func addDebitCard(name: String, colorIndex: Int, account: BankAccountItem?) {
        let newItem: DebitCardItem = createItem(DebitCardItem.self) { item in
            item.name = name
            item.colorIndexValue = Int16(colorIndex)
            item.linkedAccount = account
            item.typeValue = 2
        }
        debitCard.append(newItem)
    }
    
    func addCreditCard(name: String, colorIndex: Int, account: BankAccountItem?, withdrawalDate: Int16, startDate: Int16) {
        let newItem: CreditCardItem = createItem(CreditCardItem.self) { item in
            item.name = name
            item.colorIndexValue = Int16(colorIndex)
            item.linkedAccount = account
            item.withdrawalDay = withdrawalDate
            item.startDay = startDate
            item.typeValue = 3
        }
        creditCard.append(newItem)
    }
    
    func updateAssetItem(with item: AssetItem, name: String, colorIndex: Int, balance: Int64 = 0, account: BankAccountItem? = nil, withdrawalDate: Int16 = 1, startDate: Int16 = 1) {
        item.name = name
        item.colorIndexValue = Int16(colorIndex)
        switch item {
        case let cash as CashItem:
            cash.balance = balance
        case let bank as BankAccountItem:
            bank.balance = balance
        case let debit as DebitCardItem:
            debit.linkedAccount = account
        case let credit as CreditCardItem:
            credit.linkedAccount = account
            credit.startDay = startDate
            credit.withdrawalDay = withdrawalDate
        default: break
        }
        CoreDataManager.shared.saveContext()
    }
    
    func deleteAssetItem(with item: AssetItem) {
        switch item {
        case _ as CashItem:
            return
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
