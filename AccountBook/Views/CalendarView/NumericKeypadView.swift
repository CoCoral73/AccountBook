//
//  NumericKeypadView.swift
//  AccountBook
//
//  Created by 김정원 on 12/16/25.
//

import UIKit

class NumericKeypadView: UIView {
    static func loadFromNib() -> NumericKeypadView {
        return UINib(nibName: "NumericKeypadView", bundle: nil).instantiate(withOwner: nil).first as! NumericKeypadView
    }

}
