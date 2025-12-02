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
    
    override func viewDidLoad() {
        super.viewDidLoad()

    }
    
    @IBAction func closeButtonTapped(_ sender: UIButton) {
        dismiss(animated: true)
    }
    
    @IBAction func numberPadTapped(_ sender: UIButton) {
        let tag = sender.tag
        
    }
    
}
