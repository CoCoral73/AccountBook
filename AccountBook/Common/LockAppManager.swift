//
//  LockAppManager.swift
//  AccountBook
//
//  Created by 김정원 on 12/1/25.
//

import Foundation

enum LockAppDefaultsKey {
    static let isLocked = "lockapp.isLocked"                //UserDefaults
    static let passwordKey = "lockapp.password"             //Keychain
    static let permissionState = "lockapp.biometric.permission.state" //UserDefaults
    static let useBiometricID = "lockapp.useBiometricID"    //UserDefaults
}

extension UserDefaults {
    var isLocked: Bool {
        get { bool(forKey: LockAppDefaultsKey.isLocked) }
        set { set(newValue, forKey: LockAppDefaultsKey.isLocked) }
    }
    var permissionState: BiometricPermissionState {
        get { BiometricPermissionState(rawValue: string(forKey: LockAppDefaultsKey.permissionState) ?? "") ?? .neverAsked }
        set { set(newValue.rawValue, forKey: LockAppDefaultsKey.permissionState) }
    }
    var useBiometricID: Bool {
        get { bool(forKey: LockAppDefaultsKey.useBiometricID) }
        set { set(newValue, forKey: LockAppDefaultsKey.useBiometricID) }
    }
}

class LockAppManager {
    static let shared = LockAppManager()
    private init() { }
    
    var isLocked: Bool { UserDefaults.standard.isLocked }
    var permissionState: BiometricPermissionState { UserDefaults.standard.permissionState }
    var useBiometricID: Bool { UserDefaults.standard.useBiometricID }
    
    func registerPassword(_ pw: [Int]) {
        let pw = pw.map { String($0) }.joined()
        
        let success: Bool
        switch isLocked {
        case true:
            success = KeychainManager.shared.update(value: pw, forKey: LockAppDefaultsKey.passwordKey)
        case false:
            success = KeychainManager.shared.save(value: pw, forKey: LockAppDefaultsKey.passwordKey)
        }
        
        if success {
            print("Register or Update Password: Success")
            UserDefaults.standard.isLocked = true
        } else {
            print("Register or Update Password: Fail")
        }
    }
    
    func validatePassword(_ pw: [Int]) -> Bool {
        let pw = pw.map { String($0) }.joined()
        return KeychainManager.shared.match(value: pw, forKey: LockAppDefaultsKey.passwordKey)
    }
    
    func deletePassword() {
        let success = KeychainManager.shared.delete(forKey: LockAppDefaultsKey.passwordKey)
        
        if success {
            print("Delete Password: Success")
            UserDefaults.standard.isLocked = false
            UserDefaults.standard.useBiometricID = false
        } else {
            print("Delete Password: Fail")
        }
    }
}
