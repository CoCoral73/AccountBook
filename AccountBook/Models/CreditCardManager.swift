//
//  CreditCardManager.swift
//  AccountBook
//
//  Created by 김정원 on 12/11/25.
//

class CreditCardManager {
    static let shared = CreditCardManager()
    private init() { }
    
    func calculatePeriod(withdrawalDay: Int16, startDay: Int16) -> String {
        let periodString: String
        
        if startDay == 1 {
            periodString = "전월 1일 ~ 전월 말일"
        } else {
            let endDay = startDay - 1
            if withdrawalDay <= endDay {
                periodString = "전전월 \(startDay)일 ~ 전월 \(endDay)일"
            } else {
                periodString = "전월 \(startDay)일 ~ 당월 \(endDay)일"
            }
        }
        
        return periodString
    }
}
