//
//  AssetSelectionViewController.swift
//  AccountBook
//
//  Created by 김정원 on 7/19/25.
//

import UIKit

class AssetSelectionViewController: UIViewController {

    @IBOutlet weak var cashButton: UIButton!
    @IBOutlet weak var accountButton: UIButton!
    @IBOutlet weak var debitCardButton: UIButton!
    @IBOutlet weak var creditCardButton: UIButton!
    
    var buttons: [UIButton] = []
    
    @IBOutlet weak var tableView: UITableView!
    
    var onAssetSelected: ((AssetItem) -> ())?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        configure()
        configureTableView()
    }
    
    private func configure() {
        buttons = [cashButton, accountButton, debitCardButton, creditCardButton]
    }
    
    @IBAction func PaymentTypeButtonTapped(_ sender: UIButton) {
        buttons.forEach {
            $0.backgroundColor = .systemBackground
        }
        
        sender.backgroundColor = .systemPink
    }
    

}

extension AssetSelectionViewController: UITableViewDelegate, UITableViewDataSource {
    private func configureTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        
        //최하단 여백 삭제
        tableView.contentInsetAdjustmentBehavior = .never
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let testAsset = AssetItem(context: CoreDataManager.shared.context)
        testAsset.id = UUID()
        testAsset.name = "탭탭오"
        testAsset.typeRawValue = 4
        onAssetSelected?(testAsset)
        dismiss(animated: true)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 5
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "AssetCell", for: indexPath)
        return cell
    }
    
    override func viewDidLayoutSubviews() {
        tableView.rowHeight = tableView.frame.height / 4
    }
}
