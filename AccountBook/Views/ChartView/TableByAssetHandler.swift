//
//  ByAssetHandler.swift
//  AccountBook
//
//  Created by 김정원 on 10/20/25.
//

import UIKit

class TableByAssetHandler: NSObject, UITableViewDataSource, UITableViewDelegate {
    private weak var viewModel: ChartViewModel?
    
    init(viewModel: ChartViewModel) {
        self.viewModel = viewModel
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        viewModel?.numberOfSectionsByAsset ?? 0
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel?.numberOfRowsInSectionByAsset(section: section) ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: Cell.tableByAssetCellInChart, for: indexPath) as? TableByAssetCell,
              let data = viewModel?.cellForRowAtByAsset(indexPath: indexPath) else {
            return UITableViewCell()
        }
        
        cell.configure(data.name, data.ratio, data.amount)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        guard let header = tableView.dequeueReusableHeaderFooterView(withIdentifier: "AssetSectionHeaderView") as? AssetSectionHeaderView, let data = viewModel?.viewForHeaderInSectionByAsset(section: section) else {
            return nil
        }

        header.configure(section, data.name, data.ratio, data.amount)
        
        return header
    }
    
}
