//
//  SettingTableViewController.swift
//  AccountBook
//
//  Created by 김정원 on 11/12/25.
//

import UIKit
import GoogleMobileAds

enum SettingOption {
    case incomeCategory, expenseCategory, transferCategory
    case theme, lockApp, reset
    case rating, help, contact
    
    init(indexPath: IndexPath) {
        switch (indexPath.section, indexPath.row) {
        case (0, 0):
            self = .incomeCategory
        case (0, 1):
            self = .expenseCategory
        case (0, 2):
            self = .transferCategory
        case (1, 0):
            self = .theme
        case (1, 1):
            self = .lockApp
        case (1, 2):
            self = .reset
        case (2, 0):
            self = .rating
        case (2, 1):
            self = .help
        default: //(2, 2)
            self = .contact
        }
    }
}

class SettingTableViewController: UITableViewController, ThemeApplicable, BannerViewDelegate {
    @IBOutlet weak var bannerView: BannerView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        loadBannerAd()
        startObservingTheme()
        applyTheme(ThemeManager.shared.currentTheme)
        
        tableView.sectionHeaderTopPadding = 0
    }
    
    func loadBannerAd() {
        bannerView.adSize = AdSizeLargeBanner
        bannerView.adUnitID = ADUnitID.setting
        bannerView.rootViewController = self
        bannerView.delegate = self
        bannerView.load(Request())
    }
    
    func bannerViewDidReceiveAd(_ bannerView: BannerView) {
        bannerView.alpha = 0
        UIView.animate(withDuration: 1) {
            bannerView.alpha = 1
        }
    }
    
    func applyTheme(_ theme: any AppTheme) {
        tableView.backgroundColor = theme.baseColor
    }
    
    deinit {
        stopObservingTheme()
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let option = SettingOption(indexPath: indexPath)
        
        switch option {
        case .incomeCategory:
            showCategoryListView(.income)
        case .expenseCategory:
            showCategoryListView(.expense)
        case .transferCategory:
            showCategoryListView(.transfer)
        case .theme:
            showThemeView()
        case .lockApp:
            showLockAppView()
        case .reset:
            showResetAlert()
        case .help:
            showHelpView()
        case .contact:
            showContactView()
        case .rating:
            showRatingView()
        }
        
        tableView.deselectRow(at: indexPath, animated: false)
    }
    
    func showCategoryListView(_ type: TransactionType) {
        let vm = CategoryListViewModel(type: type)
        guard let vc = storyboard?.instantiateViewController(identifier: "CategoryListViewController", creator: { coder in
            CategoryListViewController(coder: coder, viewModel: vm)
        }) else {
            print("SettingTableViewController: VC 생성 오류")
            return
        }
        
        navigationController?.pushViewController(vc, animated: true)
    }
    
    func showThemeView() {
        guard let vc = storyboard?.instantiateViewController(withIdentifier: "ThemeViewController") as? ThemeViewController else {
            print("SettingTableViewController: 테마 VC 생성 오류")
            return
        }
        
        navigationController?.pushViewController(vc, animated: true)
    }
    
    func showLockAppView() {
        guard let vc = storyboard?.instantiateViewController(withIdentifier: "LockAppViewController") as? LockAppViewController else {
            print("SettingTableViewController: 앱 잠금 VC 생성 오류")
            return
        }
        
        navigationController?.pushViewController(vc, animated: true)
    }
    
    func showResetAlert() {
        let alert = UIAlertController(title: "데이터 초기화", message: nil, preferredStyle: .actionSheet)
        let action1 = UIAlertAction(title: "거래 내역 삭제", style: .destructive) { _ in
            self.showConfirmAlert(message: "거래 내역을 삭제하시겠습니까?") {
                CoreDataManager.shared.resetAllTransactions()
            }
        }
        let action2 = UIAlertAction(title: "전체 설정 삭제", style: .destructive) { _ in
            self.showConfirmAlert(message: "전체 설정을 삭제하시겠습니까?") {
                CoreDataManager.shared.resetAllData()
            }
        }
        
        alert.addAction(action1)
        alert.addAction(action2)
        alert.addAction(UIAlertAction(title: "취소", style: .cancel))
        
        present(alert, animated: true)
    }
    
    func showConfirmAlert(message: String, handler: @escaping () -> Void) {
        let alert = UIAlertController(title: "", message: message, preferredStyle: .alert)
        let confirm = UIAlertAction(title: "삭제", style: .destructive) { _ in
            handler()
        }
        
        alert.addAction(confirm)
        alert.addAction(UIAlertAction(title: "취소", style: .cancel))
        present(alert, animated: true)
    }
    
    func showHelpView() {
        guard let vc = storyboard?.instantiateViewController(withIdentifier: "HelpViewController") as? HelpViewController else {
            print("SettingTableViewController: 도움말 VC 생성 오류")
            return
        }
        
        navigationController?.pushViewController(vc, animated: true)
    }
    
    func showContactView() {
        showMailComposer()
    }
    
    func showRatingView() {
        let appID = "6759727652"
        let urlString = "https://apps.apple.com/app/id\(appID)?action=write-review"
        if let url = URL(string: urlString) {
            UIApplication.shared.open(url)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.isHidden = false
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.navigationBar.isHidden = true
    }
}
