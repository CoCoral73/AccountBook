//
//  PaymentSelectionViewController.swift
//  AccountBook
//
//  Created by 김정원 on 7/19/25.
//

import UIKit

class PaymentSelectionViewController: UIViewController {

    @IBOutlet weak var cashButton: UIButton!
    @IBOutlet weak var accountButton: UIButton!
    @IBOutlet weak var checkcardButton: UIButton!
    @IBOutlet weak var creditcardButton: UIButton!
    
    var buttons: [UIButton] = []
    
    @IBOutlet weak var tableView: UITableView!
    
    var onPaymentSelected: (() -> ())?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        configure()
        configureTableView()
    }
    
    private func configure() {
        buttons = [cashButton, accountButton, checkcardButton, creditcardButton]
    }
    
    @IBAction func PaymentTypeButtonTapped(_ sender: UIButton) {
        buttons.forEach {
            $0.backgroundColor = .systemBackground
        }
        
        sender.backgroundColor = .systemPink
    }
    

}

extension PaymentSelectionViewController: UITableViewDelegate, UITableViewDataSource {
    private func configureTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        
        //최하단 여백 삭제
        tableView.contentInsetAdjustmentBehavior = .never
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        dismiss(animated: true)
        onPaymentSelected?()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 5
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "PaymentCell", for: indexPath)
        return cell
    }
    
    override func viewDidLayoutSubviews() {
        tableView.rowHeight = tableView.frame.height / 4
    }
}
