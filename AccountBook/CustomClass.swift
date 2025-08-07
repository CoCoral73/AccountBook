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
