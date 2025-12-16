//
//  NumericKeypadView.swift
//  AccountBook
//
//  Created by 김정원 on 12/16/25.
//

import UIKit

protocol NumericKeypadDelegate: AnyObject {
    func keypadDidInput(number: Int)
    func keypadDidOperator(op: Operator)
    func keypadDidDelete()
    func keypadDidAllClear()
    func keypadDidHide()
}

enum Operator: Int {
    case add
    case subtract
    case multiply
    case divide
    case equal
}

class NumericKeypadView: UIView {
    static func loadFromNib() -> NumericKeypadView {
        return UINib(nibName: "NumericKeypadView", bundle: nil).instantiate(withOwner: nil).first as! NumericKeypadView
    }

    weak var delegate: NumericKeypadDelegate?
    
    @IBAction func numberTapped(_ sender: UIButton) {
        delegate?.keypadDidInput(number: sender.tag)
    }
    
    @IBAction func operatorTapped(_ sender: UIButton) {
        delegate?.keypadDidOperator(op: Operator(rawValue: sender.tag)!)
    }
    
    @IBAction func deleteTapped(_ sender: UIButton) {
        delegate?.keypadDidDelete()
    }
    
    @IBAction func allClearTapped(_ sender: UIButton) {
        delegate?.keypadDidAllClear()
    }
    
    @IBAction func hideTapped(_ sender: UIButton) {
        delegate?.keypadDidHide()
    }
    
}
