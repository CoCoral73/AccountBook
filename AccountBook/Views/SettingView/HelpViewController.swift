//
//  HelpViewController.swift
//  AccountBook
//
//  Created by 김정원 on 12/11/25.
//

import UIKit
import WebKit

class HelpViewController: UIViewController, ThemeApplicable {

    @IBOutlet weak var navItem: UINavigationItem!
    @IBOutlet weak var backButton: UIBarButtonItem!
    @IBOutlet weak var webView: WKWebView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        configureNavigationBar()
        configureURL()
        
        applyTheme(ThemeManager.shared.currentTheme)
    }

    func applyTheme(_ theme: any AppTheme) {
        backButton.tintColor = theme.accentColor
    }
    
    private func configureNavigationBar() {
        let appearance = UINavigationBarAppearance()
        appearance.configureWithTransparentBackground()
        navItem.standardAppearance = appearance
    }
    private func configureURL() {
        let url = URL(string: "https://instinctive-pixie-038.notion.site/2c6a5a562f278087bb76cc207547cbde?pvs=74")!
        let request = URLRequest(url: url)
        webView.load(request)
    }
    
    @IBAction func backButtonTapped(_ sender: UIBarButtonItem) {
        navigationController?.popViewController(animated: true)
    }
    
}
