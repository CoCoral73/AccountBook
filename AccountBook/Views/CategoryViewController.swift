//
//  CategoryCollectionViewController.swift
//  AccountBook
//
//  Created by 김정원 on 8/27/25.
//

import UIKit

class CategoryViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {

    @IBOutlet weak var collectionView: UICollectionView!
    
    var viewModel: CategoryViewModel
    
    required init?(coder: NSCoder, viewModel: CategoryViewModel) {
        self.viewModel = viewModel
        super.init(coder: coder)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        bindViewModel()
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.allowsSelection = true
        collectionView.keyboardDismissMode = .onDrag
    }
    
    func bindViewModel() {
        viewModel.onDidAddCategory = { [weak self] in
            guard let self = self else { return }
            collectionView.reloadData()
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel.numberOfItems
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CategoryCell", for: indexPath) as! CategoryCollectionViewCell
        cell.viewModel = viewModel.viewModelOfCell(indexPath.item)

        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let vm = viewModel.handleDidSelectItemAt(indexPath.item) else {
            return
        }
        
        guard let addVC = storyboard?.instantiateViewController(identifier: "CategoryEditViewController", creator: { coder in
            CategoryEditViewController(coder: coder, viewModel: vm)
        }) else {
            fatalError("CategoryEditViewController 생성 에러")
        }
        
        addVC.modalPresentationStyle = .fullScreen
        present(addVC, animated: true)
    }
    
    // 위 아래 간격
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        
        return 0
        
    }

    // 옆 간격
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {

        let width = collectionView.frame.width / 5
        let size = CGSize(width: width, height: width)
        return size
    }
}

