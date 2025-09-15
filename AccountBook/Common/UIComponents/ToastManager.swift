//
//  ToastManager.swift
//  AccountBook
//
//  Created by 김정원 on 9/15/25.
//

import UIKit

class ToastManager {
    static let shared = ToastManager()
    private init() {}   // 외부에서 새로 못 만들게 막음
    
    func show(message: String, in view: UIView) {
        let toast = ToastView(message: message)
        toast.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(toast)
        
        // 시작 위치: 화면 아래
        let bottomConstraint = toast.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: 100)
        NSLayoutConstraint.activate([
            toast.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            toast.widthAnchor.constraint(lessThanOrEqualTo: view.widthAnchor, multiplier: 0.8),
            bottomConstraint
        ])
        view.layoutIfNeeded()
        
        // 올라오는 애니메이션
        bottomConstraint.constant = -50
        UIView.animate(withDuration: 0.3, animations: {
            view.layoutIfNeeded()
        }) { _ in
            // 1초 후 내려가기
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                bottomConstraint.constant = 100
                UIView.animate(withDuration: 0.3, animations: {
                    view.layoutIfNeeded()
                }) { _ in
                    toast.removeFromSuperview()
                }
            }
        }
    }
}
