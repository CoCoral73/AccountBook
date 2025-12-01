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
    @IBOutlet weak var faceIDSwitch: UISwitch!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        configureNavigationBar()
        configureUI()
        configureModifyPW()
    }
    
    func configureNavigationBar() {
        let appearance = UINavigationBarAppearance()
        appearance.configureWithTransparentBackground()
        navItem.standardAppearance = appearance
    }
    
    func configureUI() {
        //lockSwitch.isOn =
        detailViewForLockState.isHidden = !lockSwitch.isOn
        //faceIDSwitch.isOn =
    }
    
    func configureModifyPW() {
        let tap = UITapGestureRecognizer()
        tap.addTarget(self, action: #selector(modifyPWTapped))
        modifyPWView.addGestureRecognizer(tap)
    }
    
    @objc func modifyPWTapped() {
        //비밀번호 설정 뷰 present
    }

    @IBAction func backButtonTapped(_ sender: UIBarButtonItem) {
        navigationController?.popViewController(animated: true)
    }
    
    @IBAction func lockSwitchChanged(_ sender: UISwitch) {
        //off -> on: 비밀번호 설정 뷰 present
        detailViewForLockState.isHidden = !lockSwitch.isOn
    }
    
    @IBAction func faceIDSwitchChanged(_ sender: UISwitch) {
    }
}
