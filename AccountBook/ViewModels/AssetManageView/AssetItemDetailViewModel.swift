//
//  AssetItemDetailViewModel.swift
//  AccountBook
//
//  Created by 김정원 on 12/27/25.
//

import Foundation

class AssetItemDetailViewModel {
    
    private var asset: AssetItem
    private var txs: [Transaction]
    
    var onShowAssetItemEditView: ((AssetItemEditViewModel) -> Void)?
    
    init(asset: AssetItem) {
        self.asset = asset
        
        var txs = Array(asset.transactions as? Set<Transaction> ?? [])
        if let account = asset as? BankAccountItem {
            txs.append(contentsOf: Array(account.withdrawals as? Set<Transaction> ?? []))
            txs.append(contentsOf: Array(account.deposits as? Set<Transaction> ?? []))
        }
        
        self.txs = txs.sorted { $0.date > $1.date }
    }
    
    var assetName: String {
        return asset.name
    }
    var colorIndex: Int {
        return asset.colorIndex
    }
    var isBalanceViewHidden: Bool {
        let type = asset.type
        return !(type == .cash || type == .bankAccount)
    }
    var isEstimatedPaymentAmountViewHidden: Bool {
        let type = asset.type
        return type != .creditCard
    }
    var balanceDisplay: String {
        var balance: Int64 = 0
        switch asset {
        case let cash as CashItem:
            balance = cash.balance
        case let bank as BankAccountItem:
            balance = bank.balance
        default:
            break
        }
        return balance.formattedWithComma + "원"
    }
    var linkedAccountDisplay: String {
        let account: String
        switch asset {
        case let debit as DebitCardItem:
            account = debit.linkedAccount?.name ?? "미지정"
        case let credit as CreditCardItem:
            account = credit.linkedAccount?.name ?? "미지정"
        default:
            return "" 
        }
        
        return "연결 계좌: \(account)"
    }
    var currentCycleAmountDisplay: String {
        switch asset {
        case let debit as DebitCardItem:
            return CardManager.shared.calculateCurrentMonthAmountForDebitCard(for: debit).formattedWithComma + "원"
        case let credit as CreditCardItem:
            guard let period = CardManager.shared.calculateCurrentMonthCycle(for: credit) else { return "" }
            return CardManager.shared.calculateCycleSpending(for: credit, cycle: period).formattedWithComma + "원"
        default:
            return ""
        }
    }
    var upcomingPaymentDateDisplay: String {
        guard let credit = asset as? CreditCardItem else { return "" }
        let date = CardManager.shared.getWithdrawalDate(withdrawalDay: credit.withdrawalDay)
        let formatter = DateFormatter()
        formatter.dateFormat = "결제 예정 금액 (MM / dd)"
        return formatter.string(from: date)
    }
    var estimatedPaymentAmountDisplay: String {
        guard let credit = asset as? CreditCardItem else { return "" }
        let withdrawalDate = CardManager.shared.getWithdrawalDate(withdrawalDay: credit.withdrawalDay)
        guard let cycle = CardManager.shared.calculateSpecificMonthCycle(for: credit, withdrawalDate: withdrawalDate) else { return "" }
        return CardManager.shared.calculateOutstandingCycleSpending(for: credit, cycle: cycle).formattedWithComma + "원"
    }
    var numberOfRowsInSection: Int {
        return txs.count
    }
    
    func cellForRowAt(_ index: Int) -> HistoryCellViewModel {
        let vm = HistoryCellViewModel(transaction: txs[index], asset: asset)
        return vm
    }
    
    func handleEditButton() {
        let vm = AssetItemEditViewModel(asset: asset)
        onShowAssetItemEditView?(vm)
    }
}
