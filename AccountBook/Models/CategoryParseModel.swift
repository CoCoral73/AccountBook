//
//  DefaultCategory.swift
//  AccountBook
//
//  Created by 김정원 on 8/1/25.
//

import Foundation

struct CategoryParseModel: Codable {
    let name: String
    let isIncome: Bool
    let iconName: String
    let orderIndex: Int16
}
