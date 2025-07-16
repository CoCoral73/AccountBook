//
//  AmountTextField.swift
//  AccountBook
//
//  Created by 김정원 on 7/16/25.
//

import UIKit

class AmountTextField: UITextField {

    override func canPerformAction(_ action: Selector, withSender sender: Any?) -> Bool {
            if action == #selector(UIResponderStandardEditActions.paste(_:)) {
                return false
            }
            return super.canPerformAction(action, withSender: sender)
       }
}
