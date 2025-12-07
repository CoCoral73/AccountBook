//
//  LockAppViewModel.swift
//  AccountBook
//
//  Created by 김정원 on 12/1/25.
//

class LockAppViewModel {
    
    var onUpdateLockState: (() -> Void)?
    var onRequestShowPassword: ((PasswordViewModel) -> Void)?
    
    var isOnForLockSwitch: Bool { LockAppManager.shared.isLocked }
    var isHiddenForDetailView: Bool { !LockAppManager.shared.isLocked }
    
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
}
