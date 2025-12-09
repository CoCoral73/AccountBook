//
//  LockAppManager+BiometricID.swift
//  AccountBook
//
//  Created by 김정원 on 12/5/25.
//

import LocalAuthentication

enum BiometricType {
    case none
    case touchID
    case faceID
    
    var name: String {
        switch self {
        case .none: return ""
        case .touchID: return "Touch ID"
        case .faceID: return "Face ID"
        }
    }
}

enum BiometricError {
    case none
    case notEnrolled
    case notAvailable
    case lockout
    
    var message: String {
        switch self {
        case .none:
            return ""
        case .notEnrolled:
            return "등록된 생체 정보가 없습니다."
        case .notAvailable:
            return "설정에서 생체 인증을 허용해야 합니다."
        case .lockout:
            return "생체 인증이 잠겼습니다."
        }
    }
}

extension LockAppManager {
    func deleteBiometricID() {
        UserDefaults.standard.useBiometricID = false
    }
    
    func getBiometricType() -> BiometricType {
        let context = LAContext()
        _ = context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: nil)

        switch context.biometryType {
        case .none: return .none
        case .touchID: return .touchID
        case .faceID: return .faceID
        case .opticID: return .none
        @unknown default: return .none
        }
    }
    
    func isBiometricPermissionDenied() -> BiometricError {
        let context = LAContext()
        var error: NSError?

        let result = context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error)

        if result == false {
            if let laError = error as? LAError {
                switch laError.code {
                case .biometryNotEnrolled:
                    return .notEnrolled
                case .biometryNotAvailable:
                    return .notAvailable
                case .biometryLockout:
                    return .lockout
                default:
                    break
                }
            }
        }
        return .none
    }
    
    func authenticateWithBiometrics(reason: String, completion: @escaping (Bool) -> Void) {
        let context = LAContext()
        var error: NSError?
        
        context.localizedFallbackTitle = "비밀번호 입력"
        guard context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) else {
            DispatchQueue.main.async {
                completion(false)
            }
            return
        }
        
        context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: reason) { success, _ in
            DispatchQueue.main.async { [weak self] in
                guard let self = self else { return }
                if success && !self.useBiometricID { UserDefaults.standard.useBiometricID = true }
                completion(success)
            }
        }
    }
}
