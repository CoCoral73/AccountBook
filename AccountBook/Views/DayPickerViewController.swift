//
//  DayPickerViewController.swift
//  AccountBook
//
//  Created by 김정원 on 8/16/25.
//

import UIKit

class DayPickerViewController: UIViewController {
    
    @IBOutlet weak var titleLabel: UIBarButtonItem!
    @IBOutlet weak var collectionView: IntrinsicCollectionView!
    
    var titleString: String = ""
    var onDidSelectDay: ((String, Int16) -> Void)?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        titleLabel.title = titleString
        collectionView.delegate = self
        collectionView.dataSource = self
    
    }
    
    @IBAction func closeButtonTapped(_ sender: UIBarButtonItem) {
        dismiss(animated: true)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        preferredContentSize = CGSize(width: view.bounds.width, height: 44 + collectionView.contentSize.height + view.safeAreaInsets.bottom)
    }

}

extension DayPickerViewController: UICollectionViewDelegateFlowLayout, UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let selectedDay = Int16(indexPath.item + 1)
        onDidSelectDay?(titleString, selectedDay)
        dismiss(animated: true)
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 31
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: Cell.dayCell, for: indexPath) as! DayCollectionViewCell
        cell.dayLabel.text = "\(indexPath.item + 1)"
        return cell
    }
    
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0.8  //위 아래 간격
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0.8  //옆 간격
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {

        let width = (collectionView.frame.width - 4.8) / 7
        let size = CGSize(width: width, height: width * 0.8)
        return size
    }
}
