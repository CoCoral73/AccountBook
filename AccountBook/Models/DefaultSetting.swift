//
//  Untitled.swift
//  AccountBook
//
//  Created by 김정원 on 10/25/25.
//

import Foundation

struct DefaultSetting {
    static let years: [Int] = Array(2020...2100)
    static let months: [Int] = Array(1...12)
    static let firstDate: Date = Calendar.current.date(year: 2020, month: 1)!
    static let lastDate: Date = Calendar.current.date(year: 2101, month: 1)!
}
