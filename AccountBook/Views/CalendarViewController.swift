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
    
    @IBOutlet weak var addButton: UIButton!
    @IBOutlet weak var overlayView: UIView!
    @IBOutlet weak var addContainerView: UIView!
    @IBOutlet weak var incomeButton: UIButton!
    @IBOutlet weak var expenseButton: UIButton!
    
    var viewModel: CalendarViewModel = CalendarViewModel()
    
    private var dataSource: UICollectionViewDiffableDataSource<Int, DayItem>!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        viewModel.onDidSetCurrentMonth = { [weak self] in
            guard let self = self else { return }
            self.applySnapshot()
        }
        configureCollectionView()
        configureTableView()
        addGesture()
        configureAddButtonInitialState()
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
        case .right:
            // 이전 달로 이동
            viewModel.changeMonth(by: -1)
        default:
            break
        }
    }

    private var isExpanded = false
    
    private func configureAddButtonInitialState() {
        addButton.transform = addButton.transform.rotated(by: .pi / 4)
    }
    
    @IBAction func addButtonTapped(_ sender: UIButton) {
        if !isExpanded {
            toggleAddButton(true)
            overlayView.isHidden = false
            addContainerView.isHidden = false
            
            overlayView.alpha = 0
            addContainerView.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
            UIView.animate(withDuration: 0.3, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 1) {
                self.overlayView.alpha = 0.3
                self.addContainerView.transform = .identity
            }
        } else {
            overlayTapped(UITapGestureRecognizer())
        }
        
    }
    
    private func toggleAddButton(_ state: Bool) {
        UIView.animate(withDuration: 0.1) {
            let rotation: CGFloat = self.isExpanded ? .pi/4 : -(.pi/4)
            self.addButton.transform = self.addButton.transform.rotated(by: rotation)
        }
        
        isExpanded = state
    }
    
    @IBAction private func overlayTapped(_ sender: UITapGestureRecognizer) {
        toggleAddButton(false)
        UIView.animate(withDuration: 0.05, animations: {
            self.overlayView.alpha = 0
            self.addContainerView.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
        }) { _ in
            self.overlayView.isHidden = true
            self.addContainerView.isHidden = true
            self.addContainerView.transform = .identity
        }
    }
    
    @IBAction func addTransactionButtonTapped(_ sender: UIButton) {
        viewModel.handleAddTransactionButton(type: sender.title(for: .normal)!, storyboard: storyboard, fromVC: self)
        overlayTapped(UITapGestureRecognizer())
    }
    
    
    @IBAction func monthButtonTapped(_ sender: UIButton) {
        viewModel.handleMonthButton(storyboard: storyboard, fromVC: self)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
 
        //컬렉션뷰의 컨텐츠 크기 만큼 높이 자동 조정
        let height = calendarCollectionView.collectionViewLayout.collectionViewContentSize.height

        if collectionViewHeightConstraint.constant != height {
            collectionViewHeightConstraint.constant = height
            view.layoutIfNeeded()
        }
    }
}

//MARK: Collection View
extension CalendarViewController: UICollectionViewDelegateFlowLayout {
    
    private func configureCollectionView() {
        calendarCollectionView.delegate = self
        calendarCollectionView.allowsMultipleSelection = false
        
        configureCollectionViewDataSource()
        applySnapshot()
    }
    
    private func selectDateIfNeeded() {
        if let selectedIndexPaths = calendarCollectionView.indexPathsForSelectedItems {
            for ip in selectedIndexPaths {
                calendarCollectionView.deselectItem(at: ip, animated: false)
            }
        }
        
        let date = viewModel.selectedDate
        if viewModel.isCurrentMonth(with: date) {
            if let item = viewModel.dayItemsForCurrentMonth.first(
                where: { Calendar.current.isDate($0.date, inSameDayAs: date) }
            ), let indexPath = dataSource.indexPath(for: item) {
                calendarCollectionView.selectItem(at: indexPath, animated: false, scrollPosition: [])
                if let cell = calendarCollectionView.cellForItem(at: indexPath) as? DayCollectionViewCell {
                    cell.viewModel.isSelected = true
                }
            }
        }
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
        snap.appendItems(viewModel.dayItemsForCurrentMonth, toSection: 0)
        dataSource.apply(snap, animatingDifferences: false) { [weak self] in
            self?.calendarCollectionView.layoutIfNeeded()
            self?.selectDateIfNeeded()
        }
        
        monthButton.setTitle(viewModel.monthButtonString, for: .normal)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        if let existingSelections = calendarCollectionView.indexPathsForSelectedItems {
            for oldIndexPath in existingSelections {
                calendarCollectionView.deselectItem(at: oldIndexPath, animated: false)
                if let oldCell = calendarCollectionView.cellForItem(at: oldIndexPath) as? DayCollectionViewCell {
                    oldCell.viewModel.isSelected = false
                }
            }
        }

        let selectedItem = viewModel.setSelectedDay(with: indexPath.item)

        if let newIndexPath = dataSource.indexPath(for: selectedItem) {
 
            calendarCollectionView.selectItem(
                at: newIndexPath,
                animated: false,
                scrollPosition: []
            )

            if let cell = calendarCollectionView.cellForItem(
                at: newIndexPath
            ) as? DayCollectionViewCell {
                cell.viewModel.isSelected = true
            }
        }
        
        detailTableView.reloadData()
    }
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        if let cell = collectionView.cellForItem(at: indexPath) as? DayCollectionViewCell {
            cell.viewModel.isSelected = false
        }
    }
}

//MARK: Table View
extension CalendarViewController: UITableViewDelegate, UITableViewDataSource {
    
    private func configureTableView() {
        detailTableView.delegate = self
        detailTableView.dataSource = self
        
        detailTableView.rowHeight = 50
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.numberOfRowsInSection
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = detailTableView.dequeueReusableCell(withIdentifier: Cell.detailCell, for: indexPath) as! DetailTableViewCell
        
        cell.viewModel = DetailViewModel(transaction: viewModel.cellForRowAt[indexPath.row])
        
        return cell
    }
    
}

//MARK: Month Picker View, Custom Height
extension CalendarViewController: UIViewControllerTransitioningDelegate {
    func presentationController(forPresented presented: UIViewController, presenting: UIViewController?, source: UIViewController) -> UIPresentationController? {
        return MonthPickerPresentationController(presentedViewController: presented, presenting: presentingViewController)
    }
}
class MonthPickerPresentationController: UIPresentationController {
    override var frameOfPresentedViewInContainerView: CGRect {
        guard let bounds = containerView?.bounds else { return .zero }
        let height = 260 + containerView!.safeAreaInsets.bottom
        return CGRect(x: 0, y: bounds.height - height, width: bounds.width, height: height)
    }
}
