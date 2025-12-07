//
//  LockAppViewModel.swift
//  AccountBook
//
//  Created by 김정원 on 12/1/25.
//

class LockAppViewModel {
    
    var onUpdateLockState: (() -> Void)?
    var onUpdateBiometricIDState: (() -> Void)?
    var onRequestShowPassword: ((PasswordViewModel) -> Void)?
    var onRequestUnavailableAlert: ((BiometricError) -> Void)?
    
    var isOnForLockSwitch: Bool { LockAppManager.shared.isLocked }
    var isHiddenForDetailView: Bool { !LockAppManager.shared.isLocked }
    var isHiddenForBiometricIDView: Bool { LockAppManager.shared.getBiometricType() == .none }
    var biometricTypeName: String { LockAppManager.shared.getBiometricType().name }
    var isOnForBiometricIDSwitch: Bool { LockAppManager.shared.useBiometricID }
    
    func handleModifyPW() {
        let vm = makePasswordVM(mode: .modify)
        onRequestShowPassword?(vm)
    }
    
    func handleLockSwitch(_ isOn: Bool) {
        if isOn {
            let vm = makePasswordVM(mode: .register)
            onRequestShowPassword?(vm)
        } else {
            LockAppManager.shared.deletePassword()
            onUpdateLockState?()
        }
    }
    
    func makePasswordVM(mode: PasswordMode) -> PasswordViewModel {
        let vm = PasswordViewModel(mode: mode)
        
        vm.onDidFinish = { [weak self] in
            guard let self = self else { return }
            onUpdateLockState?()
        }
        return vm
    }
    
    func handleBiometricIDSwitch(_ isOn: Bool) {
        if isOn {
            handleBiometricIDFlow()
        } else {
            LockAppManager.shared.deleteBiometricID()
        }
    }
    
    func handleBiometricIDFlow() {
        switch LockAppManager.shared.permissionState {
        case .denied:
            let error = LockAppManager.shared.isBiometricPermissionDenied()
            onRequestUnavailableAlert?(error)
        case .neverAsked, .allowed:
            LockAppManager.shared.authenticateWithBiometrics(reason: "등록") { [weak self] success in
                guard let self = self else { return }
                onUpdateBiometricIDState?()
            }
        }
    }
}
