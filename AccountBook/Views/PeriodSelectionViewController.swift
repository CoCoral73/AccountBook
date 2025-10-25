//
//  PeriodSelectionViewController.swift
//  AccountBook
//
//  Created by 김정원 on 10/23/25.
//

import UIKit

class PeriodSelectionViewController: UIViewController {

    @IBOutlet weak var borderView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        borderView.layer.cornerRadius = 20
        borderView.layer.borderWidth = 2
        borderView.layer.borderColor = UIColor.lightGray.cgColor
    }
}
