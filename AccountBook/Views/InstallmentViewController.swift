//
//  InstallmentViewController.swift
//  AccountBook
//
//  Created by 김정원 on 9/3/25.
//

import UIKit

class InstallmentViewController: UIViewController, ThemeApplicable {

    @IBOutlet weak var navigationBar: UINavigationItem!
    @IBOutlet weak var boxView: UIView!
    @IBOutlet weak var textField: UITextField!
    @IBOutlet weak var saveButton: AutoUpdateColorButton!
    
    var onDidEnterInstallment: ((Int16) -> Void)?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        startObservingTheme()
        configureNavigationBar()
        configureTextField()
        saveButton.isEnabled = false
    }
    
    func applyTheme(_ theme: any AppTheme) {
        boxView.backgroundColor = theme.baseColor
        saveButton.applyBaseColor(theme.accentColor)
    }
    
    func configureNavigationBar() {
        let appearance = UINavigationBarAppearance()
        appearance.configureWithTransparentBackground()
        navigationBar.standardAppearance = appearance
    }
    
    func configureTextField() {
        textField.delegate = self
        textField.addTarget(self, action: #selector(textDidChange), for: .editingChanged)
    }
    
    @objc func textDidChange(_ textField: UITextField) {
        let period = Int16(textField.text ?? "0") ?? 0
        if period > 1 {
            saveButton.isEnabled = true
        } else {
            saveButton.isEnabled = false
        }
    }
    
    @IBAction func backButtonTapped(_ sender: UIBarButtonItem) {
        navigationController?.popViewController(animated: true)
    }
    
    @IBAction func saveButtonTapped(_ sender: UIButton) {
        let period = Int16(textField.text ?? "0") ?? 0
        onDidEnterInstallment?(period)
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
        navigationController?.popViewController(animated: true)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        applyInitialTheme()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        view.endEditing(true)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        textField.becomeFirstResponder()
        super.viewDidAppear(animated)
    }
    
    deinit {
        stopObservingTheme()
    }
}

extension InstallmentViewController: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        // 변경 후의 최종 전체 문자열을 계산
        let currentText = textField.text ?? ""
        guard let stringRange = Range(range, in: currentText) else { return false }
        let updatedText = currentText.replacingCharacters(in: stringRange, with: string)

        // 1. 최종 문자열이 비어있는 경우(전부 삭제)는 허용
        if updatedText.isEmpty {
            return true
        }
        
        // 2. 최종 문자열을 Int16으로 변환하여 유효성 검사
        if Int(updatedText) != nil {
            return true
        }
        
        // 변환에 실패하면 입력을 막음
        textField.shake()
        return false
    }
    
}
