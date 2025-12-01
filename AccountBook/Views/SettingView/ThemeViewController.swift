//
//  ThemeViewController.swift
//  AccountBook
//
//  Created by 김정원 on 11/25/25.
//

import UIKit

class ThemeViewController: UIViewController {

    @IBOutlet weak var navItem: UINavigationItem!
    
    var viewModel: ThemeViewModel!
    
    required init?(coder: NSCoder, viewModel: ThemeViewModel) {
        self.viewModel = viewModel
        super.init(coder: coder)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        configureNavigationBar()
    }
    
    func configureNavigationBar() {
        let appearance = UINavigationBarAppearance()
        appearance.configureWithTransparentBackground()
        navItem.standardAppearance = appearance
    }

}
