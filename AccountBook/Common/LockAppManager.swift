//
//  LockAppManager.swift
//  AccountBook
//
//  Created by 김정원 on 12/1/25.
//

class LockAppManager {
    static let shared = LockAppManager()
    private init() { }
    
    private var password: String?
    
    var isLocked: Bool { password != nil }
    
    func registerPassword(_ pw: [Int]) {
        let pw = pw.map { String($0) }.joined()
        password = pw
    }
    
    func validatePassword(_ pw: [Int]) -> Bool {
        let pw = pw.map { String($0) }.joined()
        return pw == password
    }
    
    func deletePassword() {
        password = nil
    }
}
