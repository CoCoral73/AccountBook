//
//  DayPickerViewController.swift
//  AccountBook
//
//  Created by 김정원 on 8/16/25.
//

import UIKit

class DayPickerViewController: UIViewController, ThemeApplicable {
    
    @IBOutlet weak var toolBar: UIToolbar!
    @IBOutlet weak var titleLabel: UIBarButtonItem!
    @IBOutlet weak var collectionView: IntrinsicCollectionView!
    @IBOutlet weak var collectionViewHeightConstraint: NSLayoutConstraint!
    
    var titleTag: Int = 0
    var onDidSelectDay: ((Int, Int16) -> Void)?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        startObservingTheme()
        titleLabel.title = titleTag == 0 ? "출금일" : "시작일"
        collectionView.delegate = self
        collectionView.dataSource = self
    
    }
    
    func applyTheme(_ theme: any AppTheme) {
        toolBar.standardAppearance.backgroundColor = theme.baseColor
    }
    
    @IBAction func closeButtonTapped(_ sender: UIBarButtonItem) {
        dismiss(animated: true)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        applyInitialTheme()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        collectionViewHeightConstraint.constant = collectionView.collectionViewLayout.collectionViewContentSize.height
            
        // 툴바 + 컬렉션뷰 + safeArea.bottom 만큼만 뷰 높이 설정
        let totalHeight = toolBar.bounds.height + collectionViewHeightConstraint.constant
        preferredContentSize = CGSize(width: view.bounds.width, height: totalHeight)
    }

    deinit {
        stopObservingTheme()
    }
}

extension DayPickerViewController: UICollectionViewDelegateFlowLayout, UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let selectedDay = Int16(indexPath.item + 1)
        onDidSelectDay?(titleTag, selectedDay)
        dismiss(animated: true)
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 31
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: Cell.dayCell, for: indexPath) as! DayPickerCollectionViewCell
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
