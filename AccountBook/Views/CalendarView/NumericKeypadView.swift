//
//  NumericKeypadView.swift
//  AccountBook
//
//  Created by 김정원 on 12/16/25.
//

import UIKit

protocol NumericKeypadDelegate: AnyObject {
    func keypadDidInput(_ input: NumericKeypadInput)
    func keypadDidHide()
}

enum NumericKeypadInput {
    case number(Int)
    case operatorType(Operator)
    case delete
    case allClear
}

enum Operator: Int {
    case add
    case subtract
    case multiply
    case divide
    case equal
}

class NumericKeypadView: UIView, ThemeApplicable {
    
    @IBOutlet weak var addButton: UIButton!
    @IBOutlet weak var subtractButton: UIButton!
    @IBOutlet weak var multiplyButton: UIButton!
    @IBOutlet weak var divideButton: UIButton!
    @IBOutlet weak var equalButton: UIButton!
    @IBOutlet weak var acButton: UIButton!
    @IBOutlet weak var hideButton: UIButton!
    @IBOutlet weak var deleteButton: UIButton!
    
    var buttons: [UIButton] = []
    
    static func loadFromNib() -> NumericKeypadView {
        return UINib(nibName: "NumericKeypadView", bundle: nil).instantiate(withOwner: nil).first as! NumericKeypadView
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        buttons = [addButton, subtractButton, multiplyButton, divideButton, equalButton, acButton, hideButton, deleteButton]
        applyTheme(ThemeManager.shared.currentTheme)
    }
    
    func applyTheme(_ theme: any AppTheme) {
        self.backgroundColor = theme.baseColor
        buttons.forEach {
            $0.tintColor = theme.accentColor
        }
        acButton.setTitleColor(theme.accentColor, for: .normal)
    }

    weak var delegate: NumericKeypadDelegate?
    
    @IBAction func numberTapped(_ sender: UIButton) {
        delegate?.keypadDidInput(.number(sender.tag))
    }
    
    @IBAction func operatorTapped(_ sender: UIButton) {
        delegate?.keypadDidInput(.operatorType(Operator(rawValue: sender.tag)!))
    }
    
    @IBAction func deleteTapped(_ sender: UIButton) {
        delegate?.keypadDidInput(.delete)
    }
    
    @IBAction func allClearTapped(_ sender: UIButton) {
        delegate?.keypadDidInput(.allClear)
    }
    
    @IBAction func hideTapped(_ sender: UIButton) {
        delegate?.keypadDidHide()
    }
    
}
