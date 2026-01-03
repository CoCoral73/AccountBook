//
//  AssetManageTableViewHandler.swift
//  AccountBook
//
//  Created by 김정원 on 11/5/25.
//

import UIKit

class AssetInfoTableViewHandler: NSObject, UITableViewDataSource, UITableViewDelegate {
    private weak var viewModel: AssetManageViewModel?
    
    init(viewModel: AssetManageViewModel) {
        self.viewModel = viewModel
    }
    
    //MARK: DataSource
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch indexPath.section {
        case 0, 1: return 70
        case 2: return 106
        default: return 130
        }
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return section == 0 ? 0 : 40
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 4
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel?.numberOfRowsInSection(section: section) ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let id = viewModel?.withIdentifier(section: indexPath.section) else {
            print("AssetManagaTableViewHandler: id 실패")
            return UITableViewCell()
        }
        
        if indexPath.section <= 1 {    //현금, 계좌
            
            guard let cell = tableView.dequeueReusableCell(withIdentifier: id, for: indexPath) as? BalanceInfoTableViewCell,
                  let asset = viewModel?.cellForRowAt(indexPath: indexPath) else {
                print("AssetManageTableViewHandler: cell, asset 생성 오류")
                return UITableViewCell()
            }
            
            let vm = AssetItemDetailViewModel(asset: asset)
            cell.viewModel = vm
            return cell
            
        } else {    //체크카드, 신용카드
            
            guard let cell = tableView.dequeueReusableCell(withIdentifier: id, for: indexPath) as? CardInfoTableViewCell,
                  let asset = viewModel?.cellForRowAt(indexPath: indexPath) else {
                print("AssetManageTableViewHandler: cell, asset 생성 오류")
                return UITableViewCell()
            }
            
            let vm = AssetItemDetailViewModel(asset: asset)
            cell.viewModel = vm
            return cell
            
        }
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if section == 0 { return nil }
        
        guard let header = tableView.dequeueReusableHeaderFooterView(withIdentifier: "AssetInfoTableViewHeaderView") as? AssetInfoTableViewHeaderView, let data = viewModel?.viewForHeaderInSection(section: section) else {
            return nil
        }

        header.configure(data.name, data.amount)
        
        return header
    }
    
    //MARK: Delegate
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        viewModel?.didSelectRowAt(indexPath: indexPath)
    }
}
