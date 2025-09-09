//
//  DetailViewModel.swift
//  AccountBook
//
//  Created by 김정원 on 7/8/25.
//

import UIKit

class DetailTransactionViewModel {
    
    private(set) var transaction: Transaction?
    
    //DetailTransactionViewControlelr
    var onDidSetTransactionDate: (() -> Void)?
    var onDidSetCategory: (() -> Void)?
    var onDidSetAssetItem: (() -> Void)?
    var onDidSetInstallment: (() -> Void)?
    
    //CalendarViewModel
    var onDidUpdateOldDateTransaction: ((TransactionDelta) -> Void)?
    var onDidUpdateOrRemoveTransaction: ((TransactionDelta) -> Void)?
    
    init(transaction: Transaction) {
        self.transaction = transaction
    }
    
    var image: UIImage? {
        //이모지로만 돼있음. 추후 변경 필요
        return transaction?.category.iconName.toImage()
    }
    var dateString: String? {
        guard let transaction = transaction else { return nil }
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        return dateFormatter.string(from: transaction.date)
    }
    var isIncomeString: String? {
        guard let transaction = transaction else { return nil }
        return transaction.isIncome ? "수입" : "지출"
    }
    var nameString: String? {
        return transaction?.name
    }
    var categoryString: String? {
        return transaction?.category.name
    }
    var priceString: String? {
        guard let transaction = transaction else { return nil }
        return (transaction.isIncome ? "+" : "-") + self.amountString!
    }
    var amountString: String? {
        return transaction?.amount.formattedWithComma
    }
    var assetItemString: String? {
        return transaction?.asset.name
    }
    var assetType: AssetType? {
        guard let transaction = transaction else { return nil }
        return AssetType(rawValue: Int(transaction.asset.type))!
    }
    var assetTypeString: String {
        guard let assetType = assetType else { return "" }
        return transaction!.isIncome ? "**입금**" : "**\(assetType.displayName) 결제**"
    }
    var canEdit: Bool {
        return transaction?.installment == nil 
    }
    var installmentString: String {
        guard let period = transaction?.installment?.numberOfMonths else { return "일시불" }
        return "\(period) 개월"
    }
    
    var memoString: String? {
        return transaction?.memo
    }
    
    func setTransaction(with transaction: Transaction) {
        self.transaction = transaction
    }
    
    func handleDateButton(storyboard: UIStoryboard?, fromVC: UIViewController) {
        guard let transaction = transaction else { return }
        
        let vm = DatePickerViewModel(initialDate: transaction.date)
        vm.onDatePickerChanged = { [weak self] newDate in
            guard let self = self else { return }
            let oldDate = transaction.date
            let old = TransactionDelta(date: oldDate, isIncome: transaction.isIncome, amount: -transaction.amount, reason: .moveSource)
            let new = TransactionDelta(date: newDate, isIncome: transaction.isIncome, amount: transaction.amount, reason: .moveDestination)
            
            transaction.date = newDate
            onDidSetTransactionDate?()  //DetailTransactionViewController (타이틀 변경용)
            
            //월이 다르면 oldDate에 대해 UI 업데이트 안해줘도 됨. 어차피 변경 후 달력 포커스는 newDate로 감.
            if Calendar.current.isDate(oldDate, equalTo: newDate, toGranularity: .month) {
                onDidUpdateOldDateTransaction?(old)
            }
            onDidUpdateOrRemoveTransaction?(new)
        }
        
        guard let dateVC = storyboard?.instantiateViewController(identifier: "DatePickerViewController", creator: { coder in
            DatePickerViewController(coder: coder, viewModel: vm)
        }) else {
            fatalError("DatePickerViewController 생성 에러")
        }
        
        if let sheet = dateVC.sheetPresentationController {
            sheet.detents = [.medium()]
        }
        fromVC.present(dateVC, animated: true)
    }
    
    func handleCategoryButton(storyboard: UIStoryboard?, fromVC: UIViewController) {
        guard let transaction = transaction else { return }
        
        let isIncome = transaction.isIncome
        
        guard let categoryVC = storyboard?.instantiateViewController(identifier: "CategoryViewController", creator: { coder in
            CategoryViewController(coder: coder, isIncome: isIncome)
        }) else {
            fatalError("CategoryViewController 생성 에러")
        }
        
        categoryVC.onDidSelectCategory = { [weak self] category in
            guard let self = self else { return }
            transaction.category = category
            onDidSetCategory?()
        }
        
        if let sheet = categoryVC.sheetPresentationController {
            sheet.detents = [.medium()]
        }
        
        fromVC.present(categoryVC, animated: true)
    }
    
    func handleAssetItemButton(storyboard: UIStoryboard?, fromVC: UIViewController) {
        guard let transaction = transaction else { return }
        
        guard let assetSelectionVC = storyboard?.instantiateViewController(withIdentifier: "AssetSelectionViewController") as? AssetSelectionViewController
        else {
            fatalError("AssetSelectionViewController 생성 에러")
        }
        
        assetSelectionVC.onAssetSelected = { [weak self] asset in
            guard let self = self else { return }
            
            transaction.asset = asset
            onDidSetAssetItem?()
        }
        
        if let sheet = assetSelectionVC.sheetPresentationController {
            sheet.detents = [.medium()]
        }
        fromVC.present(assetSelectionVC, animated: true, completion: nil)
    }
    
    func handleInstallmentButton(storyboard: UIStoryboard?, fromVC: UIViewController) {
        guard let transaction = transaction else { return }
        
        guard let installmentVC = storyboard?.instantiateViewController(withIdentifier: "InstallmentViewController") as? InstallmentViewController
        else {
            fatalError("InstallmentViewController 생성 에러")
        }
        
        //이미 할부 정보가 존재할 경우
        if let oldPeriod = transaction.installment?.numberOfMonths {
            installmentVC.oldPeriod = oldPeriod
        }
        
        installmentVC.onDidEnterInstallment = { [weak self] period in
            guard let self = self, period > 1 else { return }

            InstallmentManager.shared.addInstallment(transaction, period: period)
            onDidSetInstallment?()
        }
        fromVC.navigationController?.pushViewController(installmentVC, animated: true)
    }
    
    func handleRemoveButton(_ fromVC: UIViewController) {
        guard let transaction = transaction else { return }
        
        let alert = UIAlertController(title: "삭제", message: "거래내역을 삭제하시겠습니까?", preferredStyle: .actionSheet)

        let success = UIAlertAction(title: "확인", style: .destructive) { [weak self] action in
            guard let self = self else { return }
            
            let delta = TransactionDelta(date: transaction.date, isIncome: transaction.isIncome, amount: -transaction.amount, reason: .deleted)
            TransactionManager.shared.deleteTransaction(transaction)
            self.transaction = nil
            
            onDidUpdateOrRemoveTransaction?(delta)
            fromVC.navigationController?.popViewController(animated: true)
        }
        let cancel = UIAlertAction(title: "취소", style: .cancel)

        alert.addAction(success)
        alert.addAction(cancel)
        fromVC.present(alert, animated: true, completion: nil)
        
    }
    
    func saveUpdatedTransaction(name: String, amount: String, memo: String) {
        guard let transaction = transaction else { return }
        
        let oldAmount = transaction.amount
        let newAmount = Int64(amount.replacingOccurrences(of: ",", with: "")) ?? 0
        
        transaction.name = name
        transaction.amount = newAmount
        transaction.memo = memo
        
        if let installment = transaction.installment, oldAmount != newAmount {
            InstallmentManager.shared.updateInstallment(with: installment, totalAmount: newAmount)
        }
        
        CoreDataManager.shared.saveContext()
        
        let delta = TransactionDelta(date: transaction.date, isIncome: transaction.isIncome, amount: newAmount - oldAmount, reason: .mutateSameDay)
        onDidUpdateOrRemoveTransaction?(delta)
    }
}
