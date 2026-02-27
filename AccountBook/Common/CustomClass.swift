//
//  AmountTextField.swift
//  AccountBook
//
//  Created by 김정원 on 7/16/25.
//

import UIKit
import DGCharts

class UIEmojiTextField: UITextField {
    
    func setEmoji() {
        _ = self.textInputMode
    }
    
    override var textInputMode: UITextInputMode? {
        for mode in UITextInputMode.activeInputModes {
            if mode.primaryLanguage == "emoji" {
                self.keyboardType = .default // do not remove this
                return mode
            }
        }
        return nil
    }
}

class AutoDismissKeyboardButton: UIButton {
    
    override func beginTracking(_ touch: UITouch, with event: UIEvent?) -> Bool {
        // 액션보다 먼저 호출되는 트래킹 시작 지점에서 키보드 내림
        self.window?.endEditing(true)
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
        return super.beginTracking(touch, with: event)
    }
    
}

class HairlineView: UIView {
    override init(frame: CGRect) {
        super.init(frame: frame)
        setContentHuggingPriority(.required, for: .vertical)
        setContentCompressionResistancePriority(.required, for: .vertical)
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setContentHuggingPriority(.required, for: .vertical)
        setContentCompressionResistancePriority(.required, for: .vertical)
    }

    override var intrinsicContentSize: CGSize {
        let pixel = 1.0 / UIScreen.main.scale
        return CGSize(width: UIView.noIntrinsicMetric, height: pixel)
    }
}

class VerticalHairlineView: UIView {
    override init(frame: CGRect) {
        super.init(frame: frame)
        setContentHuggingPriority(.required, for: .horizontal)
        setContentCompressionResistancePriority(.required, for: .horizontal)
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setContentHuggingPriority(.required, for: .horizontal)
        setContentCompressionResistancePriority(.required, for: .horizontal)
    }

    override var intrinsicContentSize: CGSize {
        let pixel = 1.0 / UIScreen.main.scale
        return CGSize(width: pixel, height: UIView.noIntrinsicMetric)
    }
}

class IntrinsicCollectionView: UICollectionView {
    override var contentSize: CGSize {
        didSet {
            // 레이아웃이 바뀔 때마다 intrinsicContentSize를 갱신
            invalidateIntrinsicContentSize()
        }
    }
  
    override var intrinsicContentSize: CGSize {
    // 콘텐츠 높이만 반환 (너비는 auto layout에 맡김)
        return CGSize(width: UIView.noIntrinsicMetric, height: contentSize.height)
    }
}

class IntrinsicTableView: UITableView {
    override var contentSize: CGSize {
        didSet {
            invalidateIntrinsicContentSize()
        }
    }
    
    override var intrinsicContentSize: CGSize {
        return CGSize(width: UIView.noIntrinsicMetric, height: contentSize.height)
    }
}

//점선 UIView
@IBDesignable
class DashedLineView: UIView {

    @IBInspectable var lineColor: UIColor = .black
    @IBInspectable var lineWidth: CGFloat = 2.0
    @IBInspectable var dashLength: CGFloat = 5.0
    @IBInspectable var dashGap: CGFloat = 5.0

    private var dashedLineLayer: CAShapeLayer!

    override func layoutSubviews() {
        super.layoutSubviews()

        // 기존 레이어 제거
        dashedLineLayer?.removeFromSuperlayer()

        // 새로운 레이어 생성 및 설정
        dashedLineLayer = CAShapeLayer()
        dashedLineLayer.strokeColor = lineColor.cgColor
        dashedLineLayer.lineWidth = lineWidth
        dashedLineLayer.lineDashPattern = [dashLength, dashGap] as [NSNumber]
        dashedLineLayer.fillColor = nil

        let path = UIBezierPath()
        path.move(to: CGPoint(x: 0, y: bounds.midY))
        path.addLine(to: CGPoint(x: bounds.width, y: bounds.midY))

        dashedLineLayer.path = path.cgPath

        self.layer.addSublayer(dashedLineLayer)
    }
}
