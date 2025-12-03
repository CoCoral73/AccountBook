//
//  PasswordViewModel.swift
//  AccountBook
//
//  Created by 김정원 on 12/2/25.
//

enum PasswordMode {
    case register
    case modify
    case validate
}

enum PasswordStep: Int {
    case first
    case confirm
}

class PasswordViewModel {
    private var mode: PasswordMode
    private var length: Int = 4
    
    var onUpdateDigit: ((Int, String) -> Void)?
    var onUpdateMessage: ((String) -> Void)?
    var onResetDigits: (() -> Void)?
    
    var onFinishRegister: ((Bool) -> Void)?
    var onFinishValidate: ((Bool) -> Void)?
    var onDidFinish: ((Bool) -> Void)?

    private var step: PasswordStep = .first
    private var curPos: Int = 0
    private var input: [[Int]] = [[],[]]
    
    init(mode: PasswordMode) {
        self.mode = mode
    }
    
    var initialMessage: String {
        switch mode {
        case .register, .modify:
            return "새로운 비밀번호를 입력해주세요."
        case .validate:
            return "비밀번호를 입력해주세요."
        }
    }
    
    func handleNumberPad(tag: Int) {
        if tag >= 0 {
            insertDigit(tag)
        } else {
            deleteDigit()
        }
    }
    
    private func insertDigit(_ number: Int) {
        guard curPos < length else { return }
        
        input[step.rawValue].append(number)
        onUpdateDigit?(curPos, "●")
        curPos += 1
        
        if curPos == length {
            completeStep()
        }
    }
    
    private func deleteDigit() {
        guard curPos > 0 else { return }
        
        curPos -= 1
        input[step.rawValue].removeLast()
        onUpdateDigit?(curPos, "—")
    }
    
    private func completeStep() {
        switch mode {
        case .register, .modify:
            handleRegisterFlow()
        case .validate:
            handleValidateFlow()
        }
    }
    
    private func handleRegisterFlow() {
        switch step {
        case .first:
            step = .confirm
            curPos = 0
            onResetDigits?()
            onUpdateMessage?("확인을 위해 한 번 더 입력해 주세요.")
        case .confirm:
            let success = (input[0] == input[1])
            onFinishRegister?(success)
            
            if success {
                LockAppManager.shared.registerPassword(input[0])
            } else {
                resetConfirmStep()
            }
        }
    }

    private func resetConfirmStep() {
        curPos = 0
        input[1] = []
        onResetDigits?()
    }
    
    private func handleValidateFlow() {
        let success = LockAppManager.shared.validatePassword(input[0])
        onFinishValidate?(success)
    }
}
