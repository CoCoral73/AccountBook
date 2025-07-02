//
//  ViewController.swift
//  AccountBook
//
//  Created by 김정원 on 7/2/25.
//

import UIKit

class CalendarViewController: UIViewController {

    @IBOutlet weak var monthButton: UIButton!
    
    @IBOutlet weak var calendarCollectionView: UICollectionView!
    @IBOutlet weak var collectionViewHeightConstraint: NSLayoutConstraint!
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        let height = calendarCollectionView.collectionViewLayout.collectionViewContentSize.height
        
        if collectionViewHeightConstraint.constant != height {
            collectionViewHeightConstraint.constant = height
            view.layoutIfNeeded()
        }
    }
    
    @IBAction func monthButtonTapped(_ sender: UIButton) {
    }
}

