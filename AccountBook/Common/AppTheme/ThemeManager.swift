//
//  ThemeManager.swift
//  AccountBook
//
//  Created by 김정원 on 11/17/25.
//

import UIKit

extension Notification.Name {
    static let themeDidChange = Notification.Name("ThemeManager.themeDidChange")
}

final class ThemeManager {

    static let shared = ThemeManager()

    private init() {
        currentKind = ThemeManager.loadSavedKind()
    }

    private(set) var currentKind: AppThemeKind {
        didSet {
            save(kind: currentKind)
            NotificationCenter.default.post(name: .themeDidChange, object: nil)
        }
    }
    
    var countOfThemes: Int { return AppThemeKind.allCases.count }
    var listOfThemes: [AppThemeKind] { return AppThemeKind.allCases }

    var currentTheme: AppTheme {
        switch currentKind {
        case .pink:
            PinkTheme()
        case .orange:
            OrangeTheme()
        case .yellow:
            YellowTheme()
        case .green:
            GreenTheme()
        case .blue:
            BlueTheme()
        case .purple:
            PurpleTheme()
        case .gray:
            GrayTheme()
        }
    }

    // 외부에서 테마 변경 요청
    func apply(kind: AppThemeKind) {
        guard currentKind != kind else { return }
        currentKind = kind
    }

    // 테마 초기화 (기본값으로 복원)
    func reset() {
        currentKind = .pink
    }

    // MARK: - 저장/로드 (UserDefaults)
    private func save(kind: AppThemeKind) {
        UserDefaults.standard.set(kind.rawValue, forKey: "AppThemeKind")
    }

    private static func loadSavedKind() -> AppThemeKind {
        let raw = UserDefaults.standard.string(forKey: "AppThemeKind") ?? AppThemeKind.pink.rawValue
        return AppThemeKind(rawValue: raw) ?? .pink
    }
}
