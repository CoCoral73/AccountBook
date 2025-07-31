//
//  InputTableViewController.swift
//  AccountBook
//
//  Created by 김정원 on 7/15/25.
//

import UIKit

class InputTableViewController: UITableViewController {
    
    @IBOutlet weak var amountTextField: AmountTextField!
    @IBOutlet weak var paymentSelectionButton: UIButton!
    @IBOutlet weak var memoTextField: UITextField!
    
    private enum Operator: Int {
        case add, subtract, multiply, divide
    }

    private var currentInput: String = ""
    private var accumulator: Int?
    private var pendingOperator: Operator?
    
    private let numberFormatter: NumberFormatter = {
        let fmt = NumberFormatter()
        fmt.numberStyle = .decimal
        fmt.groupingSeparator = ","         // 천 단위 구분자
        fmt.groupingSize = 3                // 3자리마다
        fmt.maximumFractionDigits = 0       // 소수점 없음
        return fmt
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.contentInset = UIEdgeInsets(top: -20, left: 0, bottom: -20, right: 0)
        
        configureTextField()
    }
    
    private func configureTextField() {
        amountTextField.delegate = self
        memoTextField.delegate = self

        amountTextField.becomeFirstResponder()
        configureKeyboardAccessory()
    }
    
    private func configureKeyboardAccessory() {
        let toolbar = UIToolbar()
        toolbar.isTranslucent = false
        toolbar.barTintColor = #colorLiteral(red: 0.8217506409, green: 0.8317010403, blue: 0.853022635, alpha: 1)
        toolbar.tintColor = .black
        toolbar.sizeToFit()                      // 키보드 폭에 맞춰 높이 자동 조정
        
        // 2) 탭바 느낌의 아이템 생성
        let plus = UIBarButtonItem(image: UIImage(systemName: "plus"), style: .plain, target: self, action: #selector(handleOperator))
        plus.tag = 0
        
        let minus = UIBarButtonItem(image: UIImage(systemName: "minus"), style: .plain, target: self, action: #selector(handleOperator))
        minus.tag = 1
        
        let multiply = UIBarButtonItem(image: UIImage(systemName: "multiply"), style: .plain, target: self, action: #selector(handleOperator))
        multiply.tag = 2
        let divide = UIBarButtonItem(image: UIImage(systemName: "divide"), style: .plain, target: self, action: #selector(handleOperator))
        divide.tag = 3
        
        let equal = UIBarButtonItem(image: UIImage(systemName: "equal"), style: .plain, target: self, action: #selector(handleEquals))
        
        let flexible = UIBarButtonItem(systemItem: .flexibleSpace)
        let fixed = UIBarButtonItem(systemItem: .fixedSpace)
        fixed.width = 20
        
        toolbar.items = [fixed, plus, flexible, minus, flexible, multiply, flexible, divide, flexible, equal, fixed]
        
        amountTextField.inputAccessoryView = toolbar
    }
    
    @objc func handleOperator(_ sender: UIBarButtonItem) {
        guard let currentValue = Int(currentInput) else { return }
    
        let op = Operator(rawValue: sender.tag)
        
        if accumulator == nil {
            accumulator = currentValue
        } else if let prevOp = pendingOperator {
            accumulator = perform(prevOp, accumulator!, currentValue)
            updateDisplayValue(accumulator!)
        }
        
        pendingOperator = op
        currentInput = ""
    }
    
    @objc func handleEquals() {
        guard let acc = accumulator, let prevOp = pendingOperator, let currentValue = Int(currentInput) else { return }
        
        let result = perform(prevOp, acc, currentValue)
        updateDisplayValue(result)
        
        accumulator = nil
        pendingOperator = nil
        currentInput = String(result)
    }
    
    private func perform(_ op: Operator, _ lhs: Int, _ rhs: Int) -> Int {
        switch op {
        case .add: return lhs + rhs
        case .subtract: return lhs - rhs
        case .multiply: return lhs * rhs
        case .divide: return rhs != 0 ? lhs / rhs : lhs
        }
    }
    
    private func updateDisplayValue(_ value: Int) {
        if let formatted = numberFormatter.string(from: NSNumber(value: value)) {
            amountTextField.text = formatted
            currentInput = "\(value)"
        } else {
            amountTextField.text = nil
            currentInput = ""
        }
    }
    
    @IBAction func paymentSelectionButtonTapped(_ sender: UIButton) {
        guard let paymentSelectionVC = storyboard?.instantiateViewController(withIdentifier: "PaymentSelectionViewController") as? PaymentSelectionViewController
        else {
            fatalError("PaymentSelectionViewController 생성 에러")
        }
        
        paymentSelectionVC.onPaymentSelected = { [weak self] payment in
            self?.paymentSelectionButton.setTitle(payment, for: .normal)
            self?.paymentSelectionButton.setTitleColor(.black, for: .normal)
            self?.memoTextField.becomeFirstResponder()
        }
        if let sheet = paymentSelectionVC.sheetPresentationController {
            sheet.detents = [.medium()]
        }
        present(paymentSelectionVC, animated: true, completion: nil)
    }

    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return .leastNonzeroMagnitude
    }
    override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return .leastNonzeroMagnitude
    }
}

extension InputTableViewController: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        view.endEditing(true)
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if textField == memoTextField { return true }
        
        if currentInput == "" {
            textField.text = ""
            currentInput = string
            return true
        }
        // 2) 현재 텍스트, 변경 후 텍스트 계산
        let current = textField.text ?? ""
        // range를 NSString으로 바꿔서 안전하게 replace
        let updated = (current as NSString).replacingCharacters(in: range, with: string)

        // 3) 숫자만 남기기
        let digits = updated.components(
            separatedBy: CharacterSet.decimalDigits.inverted
        ).joined()
        
        // 4) 빈 문자열이면 그대로 두기
        guard let number = Int(digits) else {
            textField.text = nil
            currentInput = ""
            return false
        }
        
        // 5) 포맷팅
        currentInput = digits
        textField.text = numberFormatter.string(from: NSNumber(value: number))
        
        return false
    }
    
}
