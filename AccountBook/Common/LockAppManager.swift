//
//  LockAppManager.swift
//  AccountBook
//
//  Created by 김정원 on 12/1/25.
//

import Foundation

enum LockAppDefaultsKey {
    static let isLocked = "lockapp.isLocked"    //UserDefaults
    static let passwordKey = "lockapp.password" //Keychain
    static let useFaceID = "lockapp.useFaceID"  //UserDefaults
}

class LockAppManager {
    static let shared = LockAppManager()
    private init() { }
    
    var isLocked: Bool { UserDefaults.standard.isLocked }
    var useFaceID: Bool { UserDefaults.standard.useFaceID }
    
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
