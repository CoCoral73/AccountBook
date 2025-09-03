//
//  InstallmentViewController.swift
//  AccountBook
//
//  Created by 김정원 on 9/3/25.
//

import UIKit

class InstallmentViewController: UIViewController {

    @IBOutlet weak var textField: UITextField!
    
    var oldPeriod: Int16?
    var onDidEnterInstallment: ((Int16) -> Void)?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        textField.delegate = self
        if let oldPeriod = oldPeriod {
            textField.text = "\(oldPeriod)"
        } else {
            textField.text = ""
        }
        textField.becomeFirstResponder()
    }

    @IBAction func backButtonTapped(_ sender: UIBarButtonItem) {
        navigationController?.popViewController(animated: true)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        let period = Int16(textField.text ?? "0") ?? 0
        onDidEnterInstallment?(period)
    }
    
}

extension InstallmentViewController: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        // 변경 후의 최종 전체 문자열을 계산
        let currentText = textField.text ?? ""
        guard let stringRange = Range(range, in: currentText) else { return false }
        let updatedText = currentText.replacingCharacters(in: stringRange, with: string)

        // 1. 최종 문자열이 비어있는 경우(전부 삭제)는 허용
        if updatedText.isEmpty {
            return true
        }
        
        // 2. 최종 문자열을 Int16으로 변환하여 유효성 검사
        if Int(updatedText) != nil {
            return true
        }
        
        // 변환에 실패하면 입력을 막음
        textField.shake()
        return false
    }
    
}
