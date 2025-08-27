//
//  DetailViewModel.swift
//  AccountBook
//
//  Created by 김정원 on 7/8/25.
//

import UIKit

class DetailTransactionViewModel {
    
    private(set) var transaction: Transaction
    
    var onDidSetTransactionDate: (() -> Void)?
    var onDidRemoveTransaction: ((NewTransactionInfo) -> Void)?
    
    init(transaction: Transaction) {
        self.transaction = transaction
    }
    
    var image: UIImage? {
        return transaction.category.iconName.toImage()
    }
    var dateString: String? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        return dateFormatter.string(from: transaction.date)
    }
    var nameString: String? {
        return transaction.name
    }
    var categoryString: String {
        return transaction.category.name
    }
    var priceString: String {
        return (transaction.isIncome ? "+" : "-") + self.amountString
    }
    var amountString: String {
        return transaction.amount.formattedWithComma
    }
    var assetString: String {
        return transaction.asset.name
    }
    var assetTypeString: String {
        return "**\(AssetType(rawValue: Int(transaction.asset.type))!.displayName) 결제**"
    }
    var memoString: String {
        return transaction.memo
    }
    
    func setTransaction(with transaction: Transaction) {
        self.transaction = transaction
    }
    
    func handleDateButton(storyboard: UIStoryboard?, fromVC: UIViewController) {
        let vm = DatePickerViewModel(initialDate: transaction.date)
        vm.onDatePickerChanged = { [weak self] date in
            guard let self = self else { return }
            self.transaction.date = date
            self.onDidSetTransactionDate?()
        }
        
        guard let dateVC = storyboard?.instantiateViewController(identifier: "DatePickerViewController", creator: { coder in
            DatePickerViewController(coder: coder, viewModel: vm) })
        else {
            fatalError("DatePickerViewController 생성 에러")
        }
        
        if let sheet = dateVC.sheetPresentationController {
            sheet.detents = [.medium()]
        }
        fromVC.present(dateVC, animated: true, completion: nil)
    }
    
    func handleRemoveButton(_ fromVC: UIViewController) {
        let alert = UIAlertController(title: "삭제", message: "거래내역을 삭제하시겠습니까?", preferredStyle: .actionSheet)

        let success = UIAlertAction(title: "확인", style: .destructive) { [weak self] action in
            guard let self = self else { return }
            
            let info = NewTransactionInfo(date: self.transaction.date, isIncome: self.transaction.isIncome, amount: -self.transaction.amount)
            TransactionManager.shared.deleteTransaction(self.transaction)
            onDidRemoveTransaction?(info)
            fromVC.navigationController?.popViewController(animated: true)
        }
        let cancel = UIAlertAction(title: "취소", style: .cancel)

        alert.addAction(success)
        alert.addAction(cancel)
        fromVC.present(alert, animated: true, completion: nil)
        
    }
}
