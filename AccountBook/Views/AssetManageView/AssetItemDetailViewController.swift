//
//  AssetItemDetailViewController.swift
//  AccountBook
//
//  Created by 김정원 on 12/27/25.
//

import UIKit

class AssetItemDetailViewController: UIViewController, ThemeApplicable {

    @IBOutlet weak var navItem: UINavigationItem!
    @IBOutlet weak var backButton: UIBarButtonItem!
    @IBOutlet weak var editButton: UIBarButtonItem!
    @IBOutlet weak var balanceView: UIView!
    @IBOutlet weak var balanceLabel: UILabel!
    @IBOutlet weak var cardView: UIView!
    @IBOutlet weak var linkedAccountLabel: UILabel!
    @IBOutlet weak var currentCycleAmountLabel: UILabel!
    @IBOutlet weak var estimatedPaymentAmountView: UIView!
    @IBOutlet weak var upcomingPaymentDateLabel: UILabel!
    @IBOutlet weak var estimatedPaymentAmountLabel: UILabel!
    @IBOutlet weak var tableView: IntrinsicTableView!
    
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
        configureTableView()
        bindViewModel()
        
        applyTheme(ThemeManager.shared.currentTheme)
    }
    
    func applyTheme(_ theme: any AppTheme) {
        backButton.tintColor = theme.accentColor
        editButton.tintColor = theme.accentColor
    }
    
    private func configureNavigationBar() {
        let appearance = UINavigationBarAppearance()
        appearance.configureWithTransparentBackground()
        navItem.standardAppearance = appearance
    }
    
    private func configureUI() {
        navItem.title = viewModel.assetName
        balanceView.isHidden = viewModel.isBalanceViewHidden
        balanceLabel.text = viewModel.balanceDisplay
        cardView.isHidden = !viewModel.isBalanceViewHidden
        linkedAccountLabel.text = viewModel.linkedAccountDisplay
        currentCycleAmountLabel.text = viewModel.currentCycleAmountDisplay
        estimatedPaymentAmountView.isHidden = viewModel.isEstimatedPaymentAmountViewHidden
        upcomingPaymentDateLabel.text = viewModel.upcomingPaymentDateDisplay
        estimatedPaymentAmountLabel.text = viewModel.estimatedPaymentAmountDisplay
    }
    
    private func bindViewModel() {
        viewModel.onShowAssetItemEditView = { [weak self] vm in
            DispatchQueue.main.async {
                self?.showAssetItemEditView(vm)
            }
        }
    }
    
    private func showAssetItemEditView(_ vm: AssetItemEditViewModel) {
        guard let vc = storyboard?.instantiateViewController(identifier: "AssetItemEditViewController", creator: { coder in
            AssetItemEditViewController(coder: coder, viewModel: vm)
        }) else {
            print("AssetItemDetailViewController: AssetItem Edit VC 생성 오류")
            return
        }
        
        vc.modalPresentationStyle = .fullScreen
        present(vc, animated: true)
    }

    @IBAction func backButtonTapped(_ sender: UIBarButtonItem) {
        navigationController?.popViewController(animated: true)
    }
    
    @IBAction func editButtonTapped(_ sender: UIBarButtonItem) {
        viewModel.handleEditButton()
    }
}

extension AssetItemDetailViewController: UITableViewDataSource {
    func configureTableView() {
        tableView.dataSource = self
        tableView.rowHeight = 70
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.numberOfRowsInSection
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: Cell.historyCell, for: indexPath) as! TransactionHistoryTableViewCell
        
        let vm = viewModel.cellForRowAt(indexPath.row)
        cell.viewModel = vm
        
        return cell
    }
    
}
