//
//  ThemeLabel.swift
//  AccountBook
//
//  Created by 김정원 on 11/17/25.
//

import UIKit

enum LabelStyle: String {
    case primary
    case secondary
}

@IBDesignable
final class ThemeLabel: UILabel, ThemeApplicable {

    @IBInspectable var lableStyle: String = "primary" {
        didSet {
            if let style = LabelStyle(rawValue: lableStyle) {
                self.style = style
            }
        }
    }

    private(set) var style: LabelStyle = .primary {
        didSet {
            applyTheme(ThemeManager.shared.currentTheme)
        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        setup()
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }

    private func setup() {
        // IBInspectable 적용값을 스타일에 반영
        if let style = LabelStyle(rawValue: lableStyle) {
            self.style = style
        }

        startObservingTheme()
        applyTheme(ThemeManager.shared.currentTheme)
    }

    func applyTheme(_ theme: AppTheme) {
        switch style {
        case .primary:
            self.textColor = theme.primaryTextColor
        case .secondary:
            self.textColor = theme.secondaryTextColor
        }
    }

    deinit {
        stopObservingTheme()
    }
}
