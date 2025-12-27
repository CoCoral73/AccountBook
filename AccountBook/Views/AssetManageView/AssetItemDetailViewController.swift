//
//  AssetItemDetailViewController.swift
//  AccountBook
//
//  Created by 김정원 on 12/27/25.
//

import UIKit

class AssetItemDetailViewController: UIViewController {

    @IBOutlet weak var navItem: UINavigationItem!
    override func viewDidLoad() {
        super.viewDidLoad()

        configureNavigationBar()
    private func configureNavigationBar() {
        let appearance = UINavigationBarAppearance()
        appearance.configureWithTransparentBackground()
        navItem.standardAppearance = appearance
    }
    
    }

}
