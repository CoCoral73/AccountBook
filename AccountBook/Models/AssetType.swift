//
//  AssetType.swift
//  AccountBook
//
//  Created by 김정원 on 8/1/25.
//

import Foundation

@objc enum PaymentType: Int16, CaseIterable {
    case cash = 0
    case bankAccount = 1
    case debitCard = 2
    case creditCard = 3

    var displayName: String {
        switch self {
        case .cash: return "현금"
        case .bankAccount: return "계좌"
        case .debitCard: return "체크카드"
        case .creditCard: return "신용카드"
        }
    }

    var iconName: String {
        switch self {
        case .cash: return "💵"
        case .bankAccount: return "🏦"
        case .debitCard: return "💳"
        case .creditCard: return "💳"
        }
    }
}
