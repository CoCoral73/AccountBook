//
//  AddViewModel.swift
//  AccountBook
//
//  Created by 김정원 on 7/9/25.
//

import UIKit

class AddTransactionViewModel {
    
    private var transactionDate: Date {
        didSet {
            onDidSetTransactionDate?()
        }
    }
    
    var amountInput: Int64 = 0
    var assetInput: AssetItem?
    var nameInput: String = ""
    
    private(set) var isIncome: Bool
    
    //Add View에서 currentDate가 바뀌면  바 버튼 아이템의 날짜 타이틀이 바뀌도록
    var onDidSetTransactionDate: (() -> Void)?
    
    //Add View에서 내역 추가 동작을 했을 때, Calendar View에서 해야할 일
    var onDidAddTransaction: ((NewTransactionInfo) -> Void)?
    
    init(date: Date, isIncome: Bool) {
        self.transactionDate = date
        self.isIncome = isIncome
    }
    
    var transactionDateString: String {
        let df = DateFormatter()
        df.dateFormat = "yyyy년 M월 d일"
        return df.string(from: transactionDate)
    }
    
    func addTransaction(with category: Category) {
        guard let asset = assetInput else {
            //자산 선택 안됐을때 동작 설정하기
            return
        }
        
        TransactionManager.shared.addTransaction(amount: amountInput, date: transactionDate, isIncome: isIncome, name: nameInput, memo: "", category: category, asset: asset)
        onDidAddTransaction?(NewTransactionInfo(date: transactionDate, isIncome: isIncome, amount: amountInput))
    }
    
    func handleDateButton(storyboard: UIStoryboard?, fromVC: UIViewController) {
        let vm = DatePickerViewModel(initialDate: transactionDate)
        vm.onDatePickerChanged = { [weak self] date in
            guard let self = self else { return }
            self.transactionDate = date
        }
        
        guard let dateVC = storyboard?.instantiateViewController(identifier: "DatePickerViewController", creator: { coder in
            DatePickerViewController(coder: coder, viewModel: vm) })
        else {
            fatalError("DatePickerViewController 생성 에러")
        }
        
        if let sheet = dateVC.sheetPresentationController {
            sheet.detents = [.medium()]
        }
        fromVC.present(dateVC, animated: true)
    }
}
