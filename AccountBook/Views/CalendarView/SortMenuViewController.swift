//
//  SortMenuViewController.swift
//  AccountBook
//
//  Created by 김정원 on 1/23/26.
//

import UIKit

class SortMenuViewController: UIViewController {

    var onDidTapButton: ((Int, String) -> Void)?
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    @IBAction func buttonTapped(_ sender: UIButton) {
        onDidTapButton?(sender.tag, sender.title(for: .normal) ?? "")
        dismiss(animated: true)
    }
}
