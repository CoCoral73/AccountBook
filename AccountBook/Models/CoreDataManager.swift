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
        persistentContainer = NSPersistentContainer(name: "AccountBook")
        persistentContainer.loadPersistentStores { storeDescription, error in
            if let error = error {
                fatalError("Core Data error: \(error)")
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
            fatalError("Core Data save error: \(nsError), \(nsError.userInfo)")
        }
    }

    func seedDataIfNeeded() {
        seedDefaultCategoriesIfNeeded()
        seedCashAssetItemIfNeeded()
    }
    
    // MARK: - Load and Insert Default Categories from JSON
    func seedDefaultCategoriesIfNeeded() {
        let request: NSFetchRequest<Category> = Category.fetchRequest()
        request.fetchLimit = 1

        do {
            let count = try context.count(for: request)
            if count == 0 {
                seedDefaultCategoriesFromJSON()
            } else {
                print("이미 기본 카테고리가 존재합니다.")
            }
        } catch {
            print("카테고리 개수 확인 중 에러 발생: \(error)")
        }
    }

    private func seedDefaultCategoriesFromJSON() {
        guard let url = Bundle.main.url(forResource: "DefaultCategory", withExtension: "json") else {
            print("DefaultCategory.json 파일을 찾을 수 없습니다.")
            return
        }

        do {
            let data = try Data(contentsOf: url)
            let decoder = JSONDecoder()
            let categories = try decoder.decode([CategoryParseModel].self, from: data)

            for category in categories {
                let newCategory = Category(context: context)
                newCategory.id = UUID()
                newCategory.name = category.name
                newCategory.isIncome = category.isIncome
                newCategory.iconName = category.iconName
                newCategory.isDefault = true
                newCategory.transactions = nil
            }

            saveContext()
            print("기본 카테고리 로드 완료!")

        } catch {
            print("기본 카테고리 로드 실패: \(error)")
        }
    }
    
    // MARK: - 전체 카테고리 로드
    func fetchCategories() -> [Category] {
        let request: NSFetchRequest<Category> = Category.fetchRequest()
        //request.sortDescriptors = [NSSortDescriptor(key: "name", ascending: true)]
        return (try? context.fetch(request)) ?? []
    }
    
    // MARK: - 특정 날짜 거래 내역 조회
    func fetchTransactions(with date: Date) -> [Transaction] {
        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: date)
        guard let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay) else {
            return []
        }

        let request: NSFetchRequest<Transaction> = Transaction.fetchRequest()
        request.predicate = NSPredicate(format: "date >= %@ AND date < %@", startOfDay as NSDate, endOfDay as NSDate)
        request.sortDescriptors = [NSSortDescriptor(key: "date", ascending: true)]

        do {
            return try context.fetch(request)
        } catch {
            print("Core Data fetch error: \(error)")
            return []
        }
    }
    
    //MARK: - 월별 거래 내역 조회
    func fetchTransactions(containing date: Date) -> [Transaction] {
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
    
    func seedCashAssetItemIfNeeded() {
        let request: NSFetchRequest<AssetItem> = AssetItem.fetchRequest()
        request.fetchLimit = 1
        
        do {
            let count = try context.count(for: request)
            if count == 0 {
                let cashAsset = AssetItem(context: context)
                cashAsset.id = UUID()
                cashAsset.name = "현금"
                cashAsset.typeRawValue = 0
                cashAsset.transactions = nil
                
                saveContext()
                print("기본 현금 자산 로드 완료!")
                
            } else {
                print("이미 기본 현금 자산이 존재합니다.")
            }
        } catch {
            print("자산 개수 확인 중 에러 발생: \(error)")
        }
    }
    
    func fetchAssetItems() -> [AssetItem] {
        let request: NSFetchRequest<AssetItem> = AssetItem.fetchRequest()
        return (try? context.fetch(request)) ?? []
    }
//
//    // MARK: - 카테고리별 합계 조회 예시
//    /// 카테고리별 총합을 딕셔너리로 반환합니다.
//    func fetchTotalsByCategory(for date: Date) -> [String: Int64] {
//        let transactions = fetchTransactionsForMonth(containing: date)
//        var totals: [String: Int64] = [:]
//
//        for tx in transactions {
//            let categoryName = tx.category.name
//            let current = totals[categoryName] ?? 0
//            totals[categoryName] = current + tx.amount
//        }
//        return totals
//    }
}
