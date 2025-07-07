//
//  CoreDataManager.swift
//  AccountBook
//
//  Created by 김정원 on 7/4/25.
//

import UIKit
import CoreData

/// Core Data 관리 매니저
final class CoreDataManager {
    // 싱글톤 인스턴스
    static let shared = CoreDataManager()

    // Persistent Container
    let persistentContainer: NSPersistentContainer

    // 편의 뷰 컨텍스트 참조
    var context: NSManagedObjectContext {
        return persistentContainer.viewContext
    }

    // MARK: - 초기화
    private init() {
        persistentContainer = NSPersistentContainer(name: "AccountBookModel")
        persistentContainer.loadPersistentStores { storeDescription, error in
            if let error = error {
                fatalError("Unresolved Core Data error: \(error)")
            }
        }
    }

    // MARK: - 저장
    func saveContext() {
        guard context.hasChanges else { return }
        do {
            try context.save()
        } catch {
            let nsError = error as NSError
            fatalError("Unresolved Core Data save error: \(nsError), \(nsError.userInfo)")
        }
    }

    // MARK: - 특정 날짜 거래 내역 조회
    func fetchTransactionsForMonth(containing date: Date) -> [Transaction] {
        let calendar = Calendar.current
        
        // 1) 이번 달 1일 00:00
        let comps = calendar.dateComponents([.year, .month], from: date)
        let startOfMonth = calendar.date(from: comps)!
        
        // 2) 다음 달 1일 00:00
        var nextMonthComps = DateComponents()
        nextMonthComps.month = 1
        let startOfNextMonth = calendar.date(byAdding: nextMonthComps,
                                             to: startOfMonth)!
        
        let request: NSFetchRequest<Transaction> = Transaction.fetchRequest()
        request.predicate = NSPredicate(
            format: "date >= %@ AND date < %@",
            startOfMonth as NSDate,
            startOfNextMonth as NSDate
        )
        request.sortDescriptors = [
            NSSortDescriptor(key: "date", ascending: true)
        ]
        
        do {
            return try context.fetch(request)
        } catch {
            print("Core Data fetch error: \(error)")
            return []
        }
    }

    // MARK: - 카테고리별 합계 조회 예시
    /// 카테고리별 총합을 딕셔너리로 반환합니다.
    func fetchTotalsByCategory(for date: Date) -> [String: Int64] {
        let transactions = fetchTransactionsForMonth(containing: date)
        var totals: [String: Int64] = [:]

        for tx in transactions {
            let categoryName = tx.category?.name ?? "Unknown"
            let current = totals[categoryName] ?? 0
            totals[categoryName] = current + tx.amount
        }
        return totals
    }
}
