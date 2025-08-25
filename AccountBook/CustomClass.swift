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
