//
//  CategoryCollectionViewController.swift
//  AccountBook
//
//  Created by 김정원 on 8/27/25.
//

import UIKit

class CategoryViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {

    @IBOutlet weak var collectionView: UICollectionView!
    
    var isIncome: Bool
    var categories: [Category] = []
    
    var onDidSelectCategory: ((Category) -> Void)?
    
    required init?(coder: NSCoder, isIncome: Bool) {
        self.isIncome = isIncome
        self.categories = isIncome ? CategoryManager.shared.incomeCategories : CategoryManager.shared.expenseCategories
        super.init(coder: coder)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.allowsSelection = true
        
        configureGesture()
    }
    
    private func configureGesture() {
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(handlePanGesture))
        collectionView.addGestureRecognizer(panGesture)
    }
    
    @objc func handlePanGesture(_ sender: UIPanGestureRecognizer) {
        if sender.state == .began {
            self.parent?.view.endEditing(true)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return isIncome ? CategoryManager.shared.incomeCategories.count : CategoryManager.shared.expenseCategories.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CategoryCell", for: indexPath) as! CategoryCollectionViewCell
        cell.viewModel = CategoryCellViewModel(category: categories[indexPath.item])

        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        let selected = categories[indexPath.item]
        onDidSelectCategory?(selected)
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

