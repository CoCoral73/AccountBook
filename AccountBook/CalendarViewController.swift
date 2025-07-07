//
//  ViewController.swift
//  AccountBook
//
//  Created by 김정원 on 7/2/25.
//

import UIKit

class CalendarViewController: UIViewController {

    @IBOutlet weak var monthButton: UIButton!
    
    @IBOutlet weak var boxView: UIView!
    
    @IBOutlet weak var plusMoneyLabel: UILabel!
    @IBOutlet weak var minusMoneyLabel: UILabel!
    @IBOutlet weak var totalStateLabel: UILabel!
    @IBOutlet weak var totalMoneyLabel: UILabel!
    
    @IBOutlet weak var calendarCollectionView: UICollectionView!
    @IBOutlet weak var collectionViewHeightConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var detailTableView: UITableView!
    
    var viewModel: CalendarViewModel = CalendarViewModel()
    
    private var dataSource: UICollectionViewDiffableDataSource<Int, DayItem>!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureCollectionView()
        configureTableView()
        addGesture()
    }
    
    func addGesture() {
        let swipeLeft = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipe(_:)))
        swipeLeft.direction = .left
        calendarCollectionView.addGestureRecognizer(swipeLeft)

        let swipeRight = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipe(_:)))
        swipeRight.direction = .right
        calendarCollectionView.addGestureRecognizer(swipeRight)
    }
    
    @objc private func handleSwipe(_ gesture: UISwipeGestureRecognizer) {
        switch gesture.direction {
        case .left:
            // 다음 달로 이동
            viewModel.changeMonth(by: +1)
            applySnapshot()
        case .right:
            // 이전 달로 이동
            viewModel.changeMonth(by: -1)
            applySnapshot()
        default:
            break
        }
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        //핑크 박스
        boxView.layer.cornerRadius = 10
        
        let height = calendarCollectionView.collectionViewLayout.collectionViewContentSize.height

        if collectionViewHeightConstraint.constant != height {
            collectionViewHeightConstraint.constant = height
            view.layoutIfNeeded()
        }
    }
    
    @IBAction func monthButtonTapped(_ sender: UIButton) {
        viewModel.handleMonthButton(storyBoard: storyboard, fromVC: self)
    }

}

//달력 구성 코드
extension CalendarViewController: UICollectionViewDelegateFlowLayout {
    
    private func configureCollectionView() {
        calendarCollectionView.delegate = self
        configureCollectionViewDataSource()
        applySnapshot()
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

        let width = calendarCollectionView.frame.width / 7
        let size = CGSize(width: width, height: width)
        return size
    }
    
    private func configureCollectionViewDataSource() {
        dataSource = UICollectionViewDiffableDataSource<Int, DayItem>(collectionView: calendarCollectionView, cellProvider: { [weak self] collectionView, indexPath, dayItem in
            guard let self = self, let cell = self.calendarCollectionView.dequeueReusableCell(withReuseIdentifier: Cell.dayCell, for: indexPath) as? DayCollectionViewCell else {
                return UICollectionViewCell()
            }
            
            cell.viewModel = DayViewModel(dayItem: dayItem, isCurrentMonth: viewModel.isCurrentMonth(with: dayItem.date))
            return cell
        })
    }
    
    func applySnapshot() {
        var snap = NSDiffableDataSourceSnapshot<Int, DayItem>()
        snap.appendSections([0])
        snap.appendItems(viewModel.generateDayItems(), toSection: 0)
        dataSource.apply(snap, animatingDifferences: false)
        
        monthButton.setTitle(viewModel.monthButtonString, for: .normal)
    }
    
}

extension CalendarViewController: UITableViewDelegate, UITableViewDataSource {
    
    private func configureTableView() {
        detailTableView.delegate = self
        detailTableView.dataSource = self
        
        detailTableView.rowHeight = 50
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = detailTableView.dequeueReusableCell(withIdentifier: Cell.detailCell, for: indexPath)
        
        return cell
    }
    
}
