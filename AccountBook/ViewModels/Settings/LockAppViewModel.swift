//
//  LockAppViewModel.swift
//  AccountBook
//
//  Created by 김정원 on 12/1/25.
//

class LockAppViewModel {
    var isLocked: Bool {
        didSet {
            onDidUpdateLockState?()
        }
    }
    
    var onDidUpdateLockState: (() -> Void)?
    var onRequestShowPassword: ((PasswordViewModel) -> Void)?
    
    init() {
        isLocked = LockAppManager.shared.isLocked
    }
    
    var isOnForLockSwitch: Bool { isLocked }
    var isHiddenForDetailView: Bool { !isLocked }
    
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
            isLocked = false
        }
    }
    
    func makePasswordVM(mode: PasswordMode) -> PasswordViewModel {
        let vm = PasswordViewModel(mode: mode)
        
        vm.onDidFinish = { [weak self] in
            guard let self = self else { return }
            self.isLocked = LockAppManager.shared.isLocked
        }
        
        return vm
    }
}
