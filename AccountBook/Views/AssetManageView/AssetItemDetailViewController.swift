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
        bindViewModel()
    }
    
    private func configureNavigationBar() {
        let appearance = UINavigationBarAppearance()
        appearance.configureWithTransparentBackground()
        navItem.standardAppearance = appearance
    }
    
    private func configureUI() {
        navItem.title = viewModel.title
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
