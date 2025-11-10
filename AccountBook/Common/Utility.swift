//
//  Logic.swift
//  AccountBook
//
//  Created by 김정원 on 10/23/25.
//

func percentage(of part: Double, in total: Double) -> Double {
    guard total != 0 else { return 0 }
    let ratio = (part / total) * 100
    return (ratio * 10).rounded() / 10
}
