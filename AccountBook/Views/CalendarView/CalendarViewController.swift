//
//  ViewController.swift
//  AccountBook
//
//  Created by 김정원 on 7/2/25.
//

import UIKit

class CalendarViewController: UIViewController, ThemeApplicable {

    @IBOutlet weak var monthButton: UIButton!
    @IBOutlet weak var searchButton: UIButton!
    
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
    @IBOutlet weak var transferButton: UIButton!
    
    var viewModel: CalendarViewModel!
    
    private var dataSource: UICollectionViewDiffableDataSource<Int, UUID>!
    private var isExpanded = false  //Add Button

    override func viewDidLoad() {
        super.viewDidLoad()
        
        addObserver()
        bindViewModel()
        configureTotals()
        configureCollectionView()
        configureTableView()
        addGesture()
        configureAddButtonInitialState()
        
        applyTheme(ThemeManager.shared.currentTheme)
    }
    
    func applyTheme(_ theme: any AppTheme) {
        searchButton.tintColor = theme.accentColor
        boxView.backgroundColor = theme.baseColor
        addButton.backgroundColor = theme.accentColor
        incomeButton.backgroundColor = theme.incomeColor
        expenseButton.backgroundColor = theme.expenseColor
        transferButton.backgroundColor = theme.transferColor
    }
    
    func addObserver() {
        NotificationCenter.default.addObserver(self, selector: #selector(txDidUpdate), name: .txDidUpdate, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(dataDidUpdate), name: .dataDidUpdate, object: nil)
        startObservingTheme()
    }
    
    @objc func txDidUpdate(_ noti: Notification) {
        let date = noti.userInfo?["date"] as! Date
        viewModel.txDidUpdate(date)
    }
    
    @objc func dataDidUpdate(_ noti: Notification) {
        detailTableView.reloadData()
    }
    
    private func bindViewModel() {
        viewModel.onDidSetCurrentMonth = { [weak self] in
            guard let self = self else { return }
            DispatchQueue.main.async {
                self.applySnapshot()
            }
        }
        
        viewModel.onRequestUpdateDayItems = { [weak self] in
            guard let self = self else { return }
            DispatchQueue.main.async {
                self.updateDayItems()
            }
        }
        
        viewModel.onRequestSelectDayItem = { [weak self] indexPath in
            guard let self = self else { return }
            DispatchQueue.main.async {
                self.selectNewCell(for: indexPath)
                self.detailTableView.reloadData()
            }
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
        let vm = viewModel.handleSearchButton()
        
        guard let vc = storyboard?.instantiateViewController(identifier: "SearchViewController", creator: { coder in
            SearchViewController(coder: coder, viewModel: vm)
        }) else {
            print("CalendarViewControlelr: Search VC 생성 오류")
            return
        }
        
        navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction func addButtonTapped(_ sender: UIButton) {
        if !isExpanded {
            toggleAddButton(true)
            
            overlayView.isHidden = false
            addContainerView.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
            addContainerView.isHidden = false
            UIView.animate(withDuration: 0.1, delay: 0, options: [.curveEaseOut]) {
                self.overlayView.alpha = 0.3
                self.addContainerView.alpha = 1
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
        UIView.animate(withDuration: 0.1, animations: {
            self.overlayView.alpha = 0
            self.addContainerView.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
            self.addContainerView.alpha = 0
        }) { _ in
            self.overlayView.isHidden = true
            self.addContainerView.isHidden = true
            self.addContainerView.transform = .identity
        }
    }
    
    @IBAction func addTransactionButtonTapped(_ sender: UIButton) {
        let vm = viewModel.handleAddTransactionButton(tag: sender.tag)
        
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
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
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
    
    func updateDayItems() {
        var snap = dataSource.snapshot()
        snap.reconfigureItems(viewModel.snapshotItems)
        dataSource.apply(snap, animatingDifferences: false) { [weak self] in
            guard let self = self else { return }
            DispatchQueue.main.async {
                self.calendarCollectionView.layoutIfNeeded()
                self.selectDateIfNeeded()
            }
        }
        
        configureTotals()
        detailTableView.reloadData()
    }
    
    func applySnapshot() {
        var snap = NSDiffableDataSourceSnapshot<Int, UUID>()
        snap.appendSections([0])
        snap.appendItems(viewModel.snapshotItems, toSection: 0)
        dataSource.apply(snap, animatingDifferences: false) { [weak self] in
            guard let self = self else { return }
            DispatchQueue.main.async {
                self.calendarCollectionView.layoutIfNeeded()
                self.selectDateIfNeeded()
            }
        }
        
        monthButton.setTitle(viewModel.monthButtonString, for: .normal)
        configureTotals()
        detailTableView.reloadData()
    }
    
    private func selectNewCell(for indexPath: IndexPath) {
        calendarCollectionView.selectItem(at: indexPath, animated: false, scrollPosition: [])
        if let cell = calendarCollectionView.cellForItem(at: indexPath) as? CalendarCollectionViewCell {
            cell.viewModel.isSelected = true
        }
    }
    
    private func selectDateIfNeeded() {
        //선택된 date가 현재 월에 포함된 날짜일 때만 선택 상태로 바꾸고 UI 업데이트
        if let id = viewModel.shouldSelectDate() {
            if let indexPath = dataSource.indexPath(for: id) {
                selectNewCell(for: indexPath)
            }
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let uuid = dataSource.itemIdentifier(for: indexPath) else { return }
        viewModel.setSelectedDate(at: indexPath, id: uuid)
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
        
        guard let detailVC = storyboard?.instantiateViewController(identifier: "TransactionDetailViewController", creator: { coder in
            TransactionDetailViewController(coder: coder, viewModel: vm)
        }) else {
            fatalError("TransactionDetailViewController 생성 에러")
        }
        
        navigationController?.pushViewController(detailVC, animated: true)
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

extension Notification.Name {
    static let txDidUpdate = Notification.Name("TxDidUpdate")
    static let dataDidUpdate = Notification.Name("dataDidUpdate")
}
