//
//  ByCategoryHandler.swift
//  AccountBook
//
//  Created by 김정원 on 10/20/25.
//

import UIKit

class TableByCategoryHandler: NSObject, UITableViewDelegate, UITableViewDataSource {
    private weak var viewModel: ChartViewModel?
    
    init(viewModel: ChartViewModel) {
        self.viewModel = viewModel
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        viewModel?.byCategoryViewModels.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: Cell.tableByCategoryCellInChart, for: indexPath) as? TableByCategoryCell,
              let vm = viewModel?.byCategoryViewModels[indexPath.row] else {
            return UITableViewCell()
        }
        
        cell.viewModel = vm
        return cell
    }
    
}
