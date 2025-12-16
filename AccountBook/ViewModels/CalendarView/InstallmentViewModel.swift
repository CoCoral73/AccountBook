//
//  InstallmentViewModel.swift
//  AccountBook
//
//  Created by 김정원 on 11/21/25.
//

class InstallmentViewModel {
    var onDidEnterInstallment: ((Int16) -> Void)?
    
    func handleSaveButton(with text: String?) {
        let period = Int16(text ?? "0") ?? 0
        onDidEnterInstallment?(period)
    }
}
