//
//  LockAppViewController.swift
//  AccountBook
//
//  Created by 김정원 on 12/1/25.
//

import UIKit

class LockAppViewController: UIViewController {

    @IBOutlet weak var navItem: UINavigationItem!
    @IBOutlet weak var lockSwitch: UISwitch!
    @IBOutlet weak var detailViewForLockState: UIStackView!
    @IBOutlet weak var modifyPWView: UIView!
    @IBOutlet weak var biometricIDView: UIStackView!
    @IBOutlet weak var biometricTypeNameLabel: UILabel!
    @IBOutlet weak var biometricIDSwitch: UISwitch!
    
    var viewModel: LockAppViewModel = LockAppViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        configureNavigationBar()
        bindViewModel()
        configureUI()
        configureModifyPW()
    }
    
    func configureNavigationBar() {
        let appearance = UINavigationBarAppearance()
        appearance.configureWithTransparentBackground()
        navItem.standardAppearance = appearance
    }
    
    func bindViewModel() {
        viewModel.onUpdateLockState = { [weak self] in
            guard let self = self else { return }
            DispatchQueue.main.async {
                self.lockSwitch.isOn = self.viewModel.isOnForLockSwitch
                self.detailViewForLockState.isHidden = self.viewModel.isHiddenForDetailView
                self.biometricIDSwitch.isOn = self.viewModel.isOnForBiometricIDSwitch
            }
        }
        
        viewModel.onUpdateBiometricIDState = { [weak self] in
            guard let self = self else { return }
            DispatchQueue.main.async {
                self.biometricIDSwitch.isOn = self.viewModel.isOnForBiometricIDSwitch
            }
        }
        
        viewModel.onRequestShowPassword = { [weak self] vm in
            guard let self = self else { return }
            DispatchQueue.main.async {
                self.showPasswordView(vm)
            }
        }
        
        viewModel.onRequestUnavailableAlert = { [weak self] error in
            guard let self = self else { return }
            DispatchQueue.main.async {
                self.biometricIDSwitch.isOn = false
                self.showUnavailableAlert(error)
            }
        }
    }
    
    func configureUI() {
        lockSwitch.isOn = viewModel.isOnForLockSwitch
        detailViewForLockState.isHidden = viewModel.isHiddenForDetailView
        biometricIDView.isHidden = viewModel.isHiddenForBiometricIDView
        biometricTypeNameLabel.text = viewModel.biometricTypeName
        biometricIDSwitch.isOn = viewModel.isOnForBiometricIDSwitch
    }
    
    func configureModifyPW() {
        let tap = UITapGestureRecognizer()
        tap.addTarget(self, action: #selector(modifyPWTapped))
        modifyPWView.addGestureRecognizer(tap)
    }
    
    @objc func modifyPWTapped() {
        viewModel.handleModifyPW()
    }

    @IBAction func backButtonTapped(_ sender: UIBarButtonItem) {
        navigationController?.popViewController(animated: true)
    }
    
    @IBAction func lockSwitchChanged(_ sender: UISwitch) {
        viewModel.handleLockSwitch(sender.isOn)
    }
    
    private func showPasswordView(_ vm: PasswordViewModel) {
        guard let vc = storyboard?.instantiateViewController(identifier: "PasswordViewController", creator: { coder in
            PasswordViewController(coder: coder, viewModel: vm)
        }) else {
            print("LockAppViewController: PasswordVC 생성 오류")
            return
        }
        
        vc.modalPresentationStyle = .fullScreen
        present(vc, animated: true)
    }
    
    private func showUnavailableAlert(_ error: BiometricError) {
        let alert = UIAlertController(title: "사용 불가", message: error.message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "확인", style: .default))
        if error == .notAvailable {
            let move = UIAlertAction(title: "설정으로 이동", style: .default) { action in
                if let url = URL(string: UIApplication.openSettingsURLString),
                   UIApplication.shared.canOpenURL(url) {
                    UIApplication.shared.open(url)
                }
            }
            alert.addAction(move)
        }
        
        present(alert, animated: true)
    }
    
    @IBAction func biometricIDSwitchChanged(_ sender: UISwitch) {
        viewModel.handleBiometricIDSwitch(sender.isOn)
    }
}
