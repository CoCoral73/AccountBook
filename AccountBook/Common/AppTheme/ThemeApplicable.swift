//
//  ThemeApplicable.swift
//  AccountBook
//
//  Created by 김정원 on 11/17/25.
//
import UIKit

protocol ThemeApplicable: AnyObject {
    func applyTheme(_ theme: AppTheme)
}

extension ThemeApplicable where Self: UIViewController {

    func startObservingTheme() {
        NotificationCenter.default.addObserver(
            forName: .themeDidChange,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            guard let self else { return }
            self.applyTheme(ThemeManager.shared.currentTheme)
        }
    }

    func stopObservingTheme() {
        NotificationCenter.default.removeObserver(self,
            name: .themeDidChange,
            object: nil)
    }
}

extension ThemeApplicable where Self: UILabel {

    func startObservingTheme() {
        NotificationCenter.default.addObserver(
            forName: .themeDidChange,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            guard let self else { return }
            self.applyTheme(ThemeManager.shared.currentTheme)
        }
    }

    func stopObservingTheme() {
        NotificationCenter.default.removeObserver(
            self,
            name: .themeDidChange,
            object: nil
        )
    }
}
