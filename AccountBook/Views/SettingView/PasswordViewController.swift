//
//  PasswordViewController.swift
//  AccountBook
//
//  Created by 김정원 on 12/2/25.
//

import UIKit

class PasswordViewController: UIViewController {
    
    @IBOutlet weak var messageLabel: UILabel!
    @IBOutlet weak var pwView: UIStackView!
    @IBOutlet weak var pw1Label: UILabel!
    @IBOutlet weak var pw2Label: UILabel!
    @IBOutlet weak var pw3Label: UILabel!
    @IBOutlet weak var pw4Label: UILabel!
    
    var viewModel: PasswordViewModel!
    
    required init?(coder: NSCoder, viewModel: PasswordViewModel) {
        self.viewModel = viewModel
        super.init(coder: coder)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    var pwLabels: [UILabel] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()

        pwLabels = [pw1Label, pw2Label, pw3Label, pw4Label]
        
        bindViewModel()
        configureUI()
    }
    
    func bindViewModel() {
        viewModel.onUpdateDigit = { [weak self] pos, ch in
            guard let self = self else { return }
            DispatchQueue.main.async {
                self.updateDigit(at: pos, with: ch)
            }
        }
        
        viewModel.onUpdateMessage = { [weak self] message in
            guard let self = self else { return }
            DispatchQueue.main.async {
                self.messageLabel.text = message
            }
        }
        
        viewModel.onResetDigits = { [weak self] in
            guard let self = self else { return }
            DispatchQueue.main.async {
                self.resetDigits()
            }
        }
        
        viewModel.onFail = { [weak self] in
            guard let self = self else { return }
            DispatchQueue.main.async {
                self.messageLabel.text = "비밀번호가 일치하지 않습니다.\n다시 시도해 주세요."
                self.pwView.shake()
                self.resetDigits()
            }
        }
        
        viewModel.onRequestDismiss = { [weak self] in
            guard let self = self else { return }
            close()
        }
    }
    
    func configureUI() {
        messageLabel.text = viewModel.initialMessage
        resetDigits()
    }
    
    func updateDigit(at index: Int, with ch: String) {
        pwLabels[index].text = ch
        pwLabels[index].textColor = (ch == "—" ? .systemGray : .black)
    }
    
    func resetDigits() {
        pwLabels.forEach {
            $0.text = "—"
            $0.textColor = .systemGray
        }
    }
    
    func close() {
        viewModel.onDidFinish?()
        dismiss(animated: true)
    }
    
    @IBAction func closeButtonTapped(_ sender: UIButton) {
        close()
    }
    
    @IBAction func numberPadTapped(_ sender: UIButton) {
        viewModel.handleNumberPad(tag: sender.tag)
    }
    
}
