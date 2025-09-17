//
//  AutoUpdateColorButton.swift
//  AccountBook
//
//  Created by 김정원 on 9/17/25.
//

import UIKit

class AutoUpdateColorButton: UIButton {
    private var baseColor: UIColor?
    
    //스토리보드 사용 시
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        baseColor = backgroundColor
        updateColor()
    }

    override var isEnabled: Bool {
        didSet {
            updateColor()
        }
    }

    private func updateColor() {
        backgroundColor = isEnabled ? baseColor : .lightGray
    }
    
    func setInvisible(_ invisible: Bool) {
        self.alpha = invisible ? 0.0 : 1.0
        self.isEnabled = !invisible
    }
}
