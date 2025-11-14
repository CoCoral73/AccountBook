//
//  CategoryListViewController.swift
//  AccountBook
//
//  Created by 김정원 on 11/12/25.
//

import UIKit

class CategoryListViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    
    var viewModel: CategoryListViewModel
    
    required init?(coder: NSCoder, viewModel: CategoryListViewModel) {
        self.viewModel = viewModel
        super.init(coder: coder)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        configureTableView()
    }
    
    @IBAction func addButtonTapped(_ sender: UIBarButtonItem) {
        let vm = CategoryEditViewModel(isIncome: viewModel.isIncome)
        vm.onDidAddCategory = {
            self.tableView.reloadData()
        }
        
        guard let vc = storyboard?.instantiateViewController(identifier: "CategoryEditViewController", creator: { coder in
            CategoryEditViewController(coder: coder, viewModel: vm)
        }) else {
            print("CategoryListViewController: VC 생성 오류")
            return
        }
        vc.presentationStyle = .push
        
        navigationController?.pushViewController(vc, animated: true)
    }

}

extension CategoryListViewController: UITableViewDataSource, UITableViewDelegate {
    
    func configureTableView() {
        tableView.dataSource = self
        tableView.delegate = self
        
        tableView.isEditing = true
        tableView.allowsSelectionDuringEditing = true
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        viewModel.numberOfRowsInSection
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CategoryListCell", for: indexPath) as! CategoryListTableViewCell
        cell.model = viewModel.cellForRowAt(row: indexPath.row)
        return cell
    }
    
    func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool { true }
    
    func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        viewModel.moveRowAt(source: sourceIndexPath.row, destination: destinationIndexPath.row)
    }
    
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        .none
    }
    
    func tableView(_ tableView: UITableView, shouldIndentWhileEditingRowAt indexPath: IndexPath) -> Bool {
        false
    }
}
