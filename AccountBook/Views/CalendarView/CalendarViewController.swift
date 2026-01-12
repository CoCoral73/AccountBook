//
//  ViewController.swift
//  AccountBook
//
//  Created by 김정원 on 7/2/25.
//

import UIKit

class CalendarViewController: UIViewController, ThemeApplicable {

    @IBOutlet weak var monthButton: UIButton!
    
    @IBOutlet weak var boxView: UIView!
    
    @IBOutlet weak var totalIncomeLabel: UILabel!
    @IBOutlet weak var totalExpenseLabel: UILabel!
    @IBOutlet weak var totalStateLabel: UILabel!
    @IBOutlet weak var totalLabel: UILabel!
    
    @IBOutlet weak var calendarCollectionView: IntrinsicCollectionView!
    @IBOutlet weak var detailTableView: UITableView!
    
    @IBOutlet weak var addButton: UIButton!
    @IBOutlet weak var overlayView: UIView!
    @IBOutlet weak var addContainerView: UIView!
    @IBOutlet weak var incomeButton: UIButton!
    @IBOutlet weak var expenseButton: UIButton!
    
    var viewModel: CalendarViewModel!
    
    private var dataSource: UICollectionViewDiffableDataSource<Int, UUID>!
    private var isExpanded = false  //Add Button

    override func viewDidLoad() {
        super.viewDidLoad()
        
        startObservingTheme()
        bindViewModel()
        configureTotals()
        configureCollectionView()
        configureTableView()
        addGesture()
        configureAddButtonInitialState()
    }
    
    func applyTheme(_ theme: any AppTheme) {
        boxView.backgroundColor = theme.baseColor
        addButton.backgroundColor = theme.accentColor
    }
    
    private func bindViewModel() {
        viewModel.onDidSetCurrentMonth = { [weak self] in
            guard let self = self else { return }
            self.applySnapshot()
        }
        
        viewModel.onDidUpdateDayItem = { [weak self] id in
            guard let self = self else { return }
            reloadDayItem(id)
        }
    }
    
    private func configureTotals() {
        totalIncomeLabel.text = viewModel.totalIncomeString
        totalExpenseLabel.text = viewModel.totalExpenseString
        totalLabel.text = viewModel.totalString
        totalStateLabel.text = viewModel.totalStateString
        
        let theme = ThemeManager.shared.currentTheme, color: UIColor
        if viewModel.totals.total < 0 { color = theme.expenseTextColor }
        else if viewModel.totals.total == 0 { color = .black }
        else { color = theme.incomeTextColor }
        totalStateLabel.textColor = color
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
    
    private func configureAddButtonInitialState() {
        addButton.transform = addButton.transform.rotated(by: .pi / 4)
    }
    
    @IBAction func searchButtonTapped(_ sender: UIButton) {
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
        let vm = viewModel.handleAddTransactionButton(tag: sender.tag)
        vm.bindCalendarUpdate(calendarVM: viewModel, fromVC: self)
        
        guard let addVC = storyboard?.instantiateViewController(identifier: "TransactionAddViewController", creator: { coder in
            TransactionAddViewController(coder: coder, viewModel: vm) })
        else {
            fatalError("TransactionAddViewController 생성 에러")
        }
        
        addVC.modalPresentationStyle = .fullScreen
        present(addVC, animated: true)
        overlayTapped(UITapGestureRecognizer())
    }
    
    
    @IBAction func monthButtonTapped(_ sender: UIButton) {
        let vm = viewModel.handleMonthButton()
        
        guard let pickerVC = storyboard?
            .instantiateViewController(identifier: "MonthPickerViewController", creator: { coder in
                MonthPickerViewController(coder: coder, viewModel: vm) })
        else {
            fatalError("MonthPickerViewController 생성 에러")
        }
        
        if let sheet = pickerVC.sheetPresentationController {
            sheet.detents = [.custom { _ in
                return 260    //44 + 216
            }]
        }

        present(pickerVC, animated: true, completion: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.isHidden = true
        applyInitialTheme()
    }
    
    deinit {
        stopObservingTheme()
    }
}

//MARK: Collection View
extension CalendarViewController {
    
    private func configureCollectionView() {
        calendarCollectionView.delegate = self
        calendarCollectionView.allowsMultipleSelection = false
        
        configureCollectionViewDataSource()
        applySnapshot()
    }
    
    private func configureCollectionViewDataSource() {
        dataSource = UICollectionViewDiffableDataSource<Int, UUID>(collectionView: calendarCollectionView, cellProvider: { [weak self] collectionView, indexPath, id in
            guard let self = self, let cell = self.calendarCollectionView.dequeueReusableCell(withReuseIdentifier: Cell.calendarCell, for: indexPath) as? CalendarCollectionViewCell, let item = viewModel.dayItemsByUUID[id] else {
                return UICollectionViewCell()
            }
            
            cell.viewModel = CalendarCellViewModel(dayItem: item, isCurrentMonth: viewModel.isCurrentMonth(with: item.date))
            return cell
        })
    }
    
    func reloadDayItem(_ id: UUID) {
        var snap = dataSource.snapshot()
        snap.reconfigureItems([id])
        dataSource.apply(snap, animatingDifferences: false) { [weak self] in
            //id에 해당하는 셀이 다시 생성되면서(reconfigureItems -> cellProvider)
            //viewModel이 새로 할당됨 -> isSelected가 false로 초기화되므로 다음 코드 필요
            //self?.calendarCollectionView.layoutIfNeeded()
            self?.selectDateIfNeeded()
        }
        configureTotals()
    }
    
    func applySnapshot() {
        var snap = NSDiffableDataSourceSnapshot<Int, UUID>()
        snap.appendSections([0])
        snap.appendItems(viewModel.snapshotItems, toSection: 0)
        dataSource.apply(snap, animatingDifferences: false) { [weak self] in
            //self?.calendarCollectionView.layoutIfNeeded()
            //컬렉션 뷰의 내부 레이아웃 미완료로 cellForItem에서 nil 반환 -> 다음 런루프로 미루기
            DispatchQueue.main.async {
                self?.selectDateIfNeeded()
            }
        }
        
        monthButton.setTitle(viewModel.monthButtonString, for: .normal)
        configureTotals()
        detailTableView.reloadData()
    }
    
    private func deselectOldCell() {
        //기존에 선택된 모든 셀들 deselect 처리
        if let selectedIndexPaths = calendarCollectionView.indexPathsForSelectedItems {
            for oldIndexPath in selectedIndexPaths {
                calendarCollectionView.deselectItem(at: oldIndexPath, animated: false)
                if let oldCell = calendarCollectionView.cellForItem(at: oldIndexPath) as? CalendarCollectionViewCell {
                    oldCell.viewModel.isSelected = false
                }
            }
        }
    }
    
    private func selectNewCell(for indexPath: IndexPath) {
        calendarCollectionView.selectItem(at: indexPath, animated: false, scrollPosition: [])
        
        if let cell = calendarCollectionView.cellForItem(at: indexPath) as? CalendarCollectionViewCell {
            cell.viewModel.isSelected = true
        }
    }
    
    private func selectDateIfNeeded() {
        
        deselectOldCell()
        
        //선택된 date가 현재 월에 포함된 날짜일 때만 선택 상태로 바꾸고 UI 업데이트
        let date = viewModel.selectedDate
        
        if viewModel.isCurrentMonth(with: date) {
            if let id = viewModel.itemIDsByDate[date], let indexPath = dataSource.indexPath(for: id) {
                selectNewCell(for: indexPath)
            }
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        deselectOldCell()
        
        guard let id = dataSource.itemIdentifier(for: indexPath), let newID = viewModel.setSelectedDate(with: id), let newIndexPath = dataSource.indexPath(for: newID) else { return }
        
        selectNewCell(for: newIndexPath)
        
        detailTableView.reloadData()
    }
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        if let cell = collectionView.cellForItem(at: indexPath) as? CalendarCollectionViewCell {
            cell.viewModel.isSelected = false
        }
    }
    
}

//MARK: Collection View Layout
extension CalendarViewController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0    //위 아래 간격
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0    //옆 간격
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {

        let width = calendarCollectionView.frame.width / 7
        let size = CGSize(width: width, height: width)
        return size
    }
    
}

//MARK: Table View
extension CalendarViewController: UITableViewDelegate, UITableViewDataSource {
    
    private func configureTableView() {
        detailTableView.delegate = self
        detailTableView.dataSource = self
        
        detailTableView.rowHeight = 50
        detailTableView.tableFooterView = UIView(frame: CGRect(x: 0, y: 0, width: detailTableView.bounds.width, height: 70))
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let cell = tableView.cellForRow(at: indexPath) as? TransactionDetailTableViewCell, let vm = cell.viewModel else {
            print("CalendarViewController: 테이블 뷰 셀 불러오기 실패")
            return
        }
        
        vm.bindCalendarUpdate(calendarVM: viewModel, fromVC: self)
        viewModel.handleDidSelectRowAt(viewModel: vm) { [weak self] in
            guard let self = self else { return }
            guard let detailVC = storyboard?.instantiateViewController(identifier: "TransactionDetailViewController", creator: { coder in
                TransactionDetailViewController(coder: coder, viewModel: vm)
            }) else {
                fatalError("TransactionDetailViewController 생성 에러")
            }
            
            navigationController?.pushViewController(detailVC, animated: true)
        }
        
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.numberOfRowsInSection
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = detailTableView.dequeueReusableCell(withIdentifier: Cell.detailCell, for: indexPath) as! TransactionDetailTableViewCell
        
        cell.viewModel = TransactionDetailViewModel(transaction: viewModel.cellForRowAt(indexPath.row))
        
        return cell
    }
    
}
