//
//  ColorPickerViewController.swift
//  AccountBook
//
//  Created by 김정원 on 1/27/26.
//

import UIKit

class ColorPickerViewController: UIViewController {
    var onDidSelectColor: ((Int) -> Void)?
    
    override func viewDidLoad() {
        super.viewDidLoad()

    }
    @IBAction func colorButtonTapped(_ sender: UIButton) {
        onDidSelectColor?(sender.tag)
        dismiss(animated: true)
    }
}
