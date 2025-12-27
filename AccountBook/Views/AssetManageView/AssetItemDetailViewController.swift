//
//  AssetItemDetailViewController.swift
//  AccountBook
//
//  Created by 김정원 on 12/27/25.
//

import UIKit

class AssetItemDetailViewController: UIViewController {

    @IBOutlet weak var navItem: UINavigationItem!
    
    var viewModel: AssetItemDetailViewModel
    
    required init?(coder: NSCoder, viewModel: AssetItemDetailViewModel) {
        self.viewModel = viewModel
        super.init(coder: coder)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        configureNavigationBar()
        configureUI()
    }
    
    private func configureNavigationBar() {
        let appearance = UINavigationBarAppearance()
        appearance.configureWithTransparentBackground()
        navItem.standardAppearance = appearance
    }
    
    private func configureUI() {
        navItem.title = viewModel.title
    }

}
