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

//콤마 자동 포맷팅 텍스트필드
class FormattedTextField: UITextField, UITextFieldDelegate {

    // MARK: - Properties

    private let formatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.locale = Locale(identifier: "ko_KR")
        formatter.maximumFractionDigits = 0 // 소수점 자릿수 제한
        return formatter
    }()
    
    // MARK: - Initialization
    required init?(coder Decoder: NSCoder) {
        super.init(coder: Decoder)
        setup()
    }
    
    // MARK: - Setup
    
    private func setup() {
        self.delegate = self
    }
    
    // MARK: - Actions
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let oldText = textField.text ?? ""
        let onlyNumberString = string.filter { $0.isNumber }.map { String($0) }.joined()
        let newText = (oldText as NSString).replacingCharacters(in: range, with: onlyNumberString)
        
        let cleanText = newText.replacingOccurrences(of: formatter.groupingSeparator, with: "")
        guard let number = Int64(cleanText) else {
            textField.text = ""
            return false
        }
        textField.text = formatter.string(for: number)
        
        if string.count > 1 {   //붙여넣기
            let endPosition = textField.endOfDocument
            textField.selectedTextRange = textField.textRange(from: endPosition, to: endPosition)
        } else {
            
        }
        
        return false
    }
    
    @objc private func textFieldDidChange() {
        guard let text = text, !text.isEmpty else { return }
        
        let onlyDigits = text.filter { $0.isNumber }.map { String($0) }.joined()
        
        guard let number = Int64(onlyDigits) else {
            self.text = ""
            return
        }
        
        self.text = formatter.string(from: NSNumber(value: number))
    }
    
    // MARK: - Public Method
    
    // 외부에 포맷되지 않은 숫자 값을 제공하는 메서드
    public func unformattedValue() -> Int64? {
        let cleanedText = self.text?.replacingOccurrences(of: formatter.groupingSeparator, with: "")
        return Int64(cleanedText ?? "0")
    }
}
