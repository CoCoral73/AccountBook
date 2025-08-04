//
//  Extension.swift
//  AccountBook
//
//  Created by 김정원 on 8/2/25.
//

import Foundation

extension Formatter {
    static let currency: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.groupingSeparator = "," // 한국어에선 기본이긴 함
        formatter.locale = Locale(identifier: "ko_KR")
        return formatter
    }()
}

extension Int64 {
    var formattedWithComma: String {
        return Formatter.currency.string(from: NSNumber(value: self)) ?? "\(self)"
    }
}
