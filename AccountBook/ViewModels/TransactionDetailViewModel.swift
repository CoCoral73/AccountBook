//
//  DetailViewModel.swift
//  AccountBook
//
//  Created by 김정원 on 7/8/25.
//

import UIKit

class TransactionDetailViewModel: TransactionUpdatable {
    
    private(set) var transaction: Transaction?
    
    //DetailTransactionViewControlelr
    var onDidSetTransactionDate: (() -> Void)?
    var onDidSetCategory: (() -> Void)?
    var onDidSetAssetItem: (() -> Void)?
    var onDidSetInstallment: (() -> Void)?
    
    //CalendarViewModel
    var onDidUpdateOldDateTransaction: ((Date) -> Void)?
    var onDidUpdateTransaction: ((Date) -> Void)?   //TransactionUpdatable
    
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
        guard let period = transaction?.installment?.numberOfMonths, let index = transaction?.installmentIndexValue else { return "일시불" }
        return "\(period) 개월 (\(index) / \(period))"
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
            
            transaction.date = newDate
            onDidSetTransactionDate?()  //TransactionDetailViewController (Date UI 변경용)
            
            //월이 다르면 oldDate에 대해 UI 업데이트 안해줘도 됨. 어차피 변경 후 달력 포커스는 newDate로 감.
            if Calendar.current.isDate(oldDate, equalTo: newDate, toGranularity: .month) {
                onDidUpdateOldDateTransaction?(oldDate)
            }
            onDidUpdateTransaction?(newDate)
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
        
        guard let assetSelectionVC = storyboard?.instantiateViewController(identifier: "AssetSelectionViewController", creator: { coder in
            AssetSelectionViewController(coder: coder, isIncome: transaction.isIncome)
        })
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
        
        installmentVC.onDidEnterInstallment = { [weak self] period in
            guard let self = self, period > 1 else { return }

            InstallmentManager.shared.addInstallment(transaction, period: period)
            
            onDidSetInstallment?()
            onDidUpdateTransaction?(transaction.date)
        }
        fromVC.navigationController?.pushViewController(installmentVC, animated: true)
    }
    
    func handleRemoveInstallmentButton(fromVC: UIViewController) {
        guard let transaction = transaction else { return }
        
        let isFirst = transaction.installmentIndexValue == 1
        
        //얼럿 띄우기
        InstallmentManager.shared.deleteInstallment(transaction)
        onDidUpdateTransaction?(transaction.date)
        
        if isFirst {
            onDidSetInstallment?()
        } else {
            self.transaction = nil
            fromVC.navigationController?.popViewController(animated: true)
        }
    }
    
    func handleRemoveButton(_ fromVC: UIViewController) {
        guard let transaction = transaction else { return }
        
        let deleteType = transaction.installment != nil ? DeleteType.installment : DeleteType.general
        let alert = UIAlertController(title: "삭제", message: deleteType.alertMessage, preferredStyle: .actionSheet)

        let success = UIAlertAction(title: "확인", style: .destructive) { [weak self] action in
            guard let self = self else { return }
            
            let date = transaction.date
            TransactionManager.shared.deleteTransaction(transaction)
            self.transaction = nil
            
            onDidUpdateTransaction?(date)
            fromVC.navigationController?.popViewController(animated: true)
        }
        let cancel = UIAlertAction(title: "취소", style: .cancel)

        alert.addAction(success)
        alert.addAction(cancel)
        fromVC.present(alert, animated: true, completion: nil)
        
    }
    
    func saveUpdatedTransaction(name: String, amount: String, memo: String) {
        guard let transaction = transaction else { return }
        
        let newAmount = Int64(amount.replacingOccurrences(of: ",", with: "")) ?? 0
        
        transaction.name = name
        transaction.amount = newAmount
        transaction.memo = memo
        
        CoreDataManager.shared.saveContext()
        
        onDidUpdateTransaction?(transaction.date)
    }
}
