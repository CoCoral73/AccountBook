//
//  AddViewController.swift
//  AccountBook
//
//  Created by 김정원 on 7/9/25.
//

import UIKit

class AddViewController: UIViewController {
    
    @IBOutlet weak var dateButton: UIBarButtonItem!
    
    @IBOutlet weak var categoryCollectionView: UICollectionView!
    
    var viewModel: AddViewModel
    
    required init?(coder: NSCoder, viewModel: AddViewModel) {
        self.viewModel = viewModel
        super.init(coder: coder)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        viewModel.onDidSetCurrentDate = { [weak self] in
            guard let self = self else { return }
            self.dateButton.title = self.viewModel.currentDateString
        }
        dateButton.title = self.viewModel.currentDateString
        
        configureCollectionView()
    }
    
    @IBAction func closeButtonTapped(_ sender: UIBarButtonItem) {
        dismiss(animated: true)
    }
    
    @IBAction func dateButtonTapped(_ sender: UIBarButtonItem) {
        viewModel.handleDateButton(storyboard: storyboard, fromVC: self)
    }
    
}

extension AddViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    private func configureCollectionView() {
        categoryCollectionView.delegate = self
        categoryCollectionView.dataSource = self
    }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 100
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = categoryCollectionView.dequeueReusableCell(withReuseIdentifier: "CategoryCell", for: indexPath) as! CategoryCollectionViewCell
        cell.viewModel = CategoryViewModel()
        return cell
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

        let width = categoryCollectionView.frame.width / 5
        let size = CGSize(width: width, height: width)
        return size
    }
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        view.endEditing(true)  // 또는 amountTextField.resignFirstResponder()
    }
    
}
