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
    
    private var dataSource: UICollectionViewDiffableDataSource<Int, DayItem>!
    private var currentMonth = Date()
    private var dayCache: [Date: [Int?]] = [:]  // 월별 날짜 배열 캐싱
    private var transactions: [Int: [Transaction]] = [:]

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureCollectionView()
        configureTableView()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        boxView.layer.cornerRadius = 10
        
        let height = calendarCollectionView.collectionViewLayout.collectionViewContentSize.height

        if collectionViewHeightConstraint.constant != height {
            collectionViewHeightConstraint.constant = height
            view.layoutIfNeeded()
        }
    }
    
    @IBAction func monthButtonTapped(_ sender: UIButton) {
    }
    
    private func loadMonthlyData() {
        // currentMonth 는 사용자가 보고 있는 월의 임의의 날짜(Date)
        let allTx = CoreDataManager.shared
                         .fetchTransactionsForMonth(containing: currentMonth)
        
        // day(1~31)별로 그룹화
        transactions = Dictionary(grouping: allTx) { tx in
            Calendar.current.component(.day, from: tx.date)
        }
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
            guard let self = self, let cell = self.calendarCollectionView.dequeueReusableCell(withReuseIdentifier: Cell.dayCell, for: indexPath) as? CalendarCollectionViewCell else {
                return UICollectionViewCell()
            }
            
            let isCurrentMonth = Calendar.current.isDate(dayItem.date, equalTo: currentMonth, toGranularity: .month)
            cell.viewModel = DayViewModel(dayItem: dayItem, isCurrentMonth: isCurrentMonth)
            return cell
        })
    }
    
    private func applySnapshot() {
        let rawDays = days(for: currentMonth)      // [Int?]
        // 이번 달 1일 Date 계산
        let comps = Calendar.current.dateComponents([.year, .month], from: currentMonth)
        let firstOfMonth = Calendar.current.date(from: comps)!
        
        let firstIndex = rawDays.firstIndex(where: { $0 != nil })!
        let lastIndex = rawDays.lastIndex(where: { $0 != nil })!
        
        var items: [DayItem] = []
        for i in 0..<rawDays.count {
            if let day = rawDays[i] {
                let date = Calendar.current.date(byAdding: .day, value: day-1, to: firstOfMonth)!
                
                let income  = transactions[day]?.reduce(0, { result, ta in
                    return result + (ta.isIncome ? ta.amount : 0)
                }) ?? 0
                let expense = transactions[day]?.reduce(0, { result, ta in
                    return result + (!ta.isIncome ? ta.amount : 0)
                }) ?? 0
                
                items.append(DayItem(date: date, income: income, expense: expense))
            } else {
                let date: Date, diff: Int
                if i < firstIndex {
                    diff = i - firstIndex
                    date = Calendar.current.date(byAdding: .day, value: diff, to: firstOfMonth)!
                }
                else {
                    diff = i - lastIndex - 1
                    let firstOfNextMonth = Calendar.current.date(byAdding: .month, value: 1, to: firstOfMonth)!
                    date = Calendar.current.date(byAdding: .day, value: diff, to: firstOfNextMonth)!
                }
                
                items.append(DayItem(date: date, income: 0, expense: 0))
            }
            
        }
//        let items: [DayItem] = rawDays.map { dayNumber in
//            if let day = dayNumber {
//                let date = Calendar.current.date(
//                    byAdding: .day,
//                    value: day - 1,
//                    to: firstOfMonth
//                )!
//            
//                let income  = transactions[day]?.reduce(0, { result, ta in
//                    return result + (ta.isIncome ? ta.amount : 0)
//                }) ?? 0
//                let expense = transactions[day]?.reduce(0, { result, ta in
//                    return result + (!ta.isIncome ? ta.amount : 0)
//                }) ?? 0
//                return DayItem(date: date, income: income, expense: expense)
//            } else {
//                
//            }
//        }
        
        // 4-2. 스냅샷에 섹션·아이템 추가
        var snap = NSDiffableDataSourceSnapshot<Int, DayItem>()
        snap.appendSections([0])
        snap.appendItems(items, toSection: 0)
        dataSource.apply(snap, animatingDifferences: false)
        monthButton.setTitle(monthTitle(from: currentMonth), for: .normal)
    }
    
    private func days(for date: Date) -> [Int?] {
        if let cached = dayCache[date] { return cached }
        let cal = Calendar.current
        let comps = cal.dateComponents([.year, .month], from: date)
        let firstOfMonth = cal.date(from: comps)!
        let weekday = cal.component(.weekday, from: firstOfMonth)   // 일=1, 월=2, …
        let daysInMonth = cal.range(of: .day, in: .month, for: date)!.count

        var arr: [Int?] = Array(repeating: nil, count: weekday - 1)
        arr += (1...daysInMonth).map { Optional($0) }
        while arr.count % 7 != 0 { arr.append(nil) }

        dayCache[date] = arr
        return arr
    }

    private func monthTitle(from date: Date) -> String {
        let df = DateFormatter()
        df.dateFormat = "yyyy년 M월"
        return df.string(from: date)
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
