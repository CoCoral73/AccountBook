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

class NumericKeypadView: UIView {
    static func loadFromNib() -> NumericKeypadView {
        return UINib(nibName: "NumericKeypadView", bundle: nil).instantiate(withOwner: nil).first as! NumericKeypadView
    }

}
