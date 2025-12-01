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
    }
    
    func configureNavigationBar() {
        let appearance = UINavigationBarAppearance()
        appearance.configureWithTransparentBackground()
        navItem.standardAppearance = appearance
    }

    @IBAction func backButtonTapped(_ sender: UIBarButtonItem) {
        navigationController?.popViewController(animated: true)
    }
    @IBAction func lockSwitchChanged(_ sender: UISwitch) {
    }
    @IBAction func faceIDSwitchChanged(_ sender: UISwitch) {
    }
}
