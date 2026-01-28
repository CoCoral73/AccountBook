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

    let calendar = Calendar.current
    
    // MARK: - 초기화
    private init() {
        persistentContainer = NSPersistentContainer(name: "AccountBook")
        
        let description = persistentContainer.persistentStoreDescriptions.first
        description?.shouldMigrateStoreAutomatically = true
        description?.shouldInferMappingModelAutomatically = true
        
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
        seedDefaultAssetItemIfNeeded()
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
                newCategory.typeValue = category.typeValue
                newCategory.iconName = category.iconName
                newCategory.orderIndex = category.orderIndex
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
        request.sortDescriptors = [NSSortDescriptor(key: "orderIndex", ascending: true)]
        return (try? context.fetch(request)) ?? []
    }
    
    // MARK: - 전체 거래 내역 조회
    func fetchTransactions() -> [Transaction] {
        let request: NSFetchRequest<Transaction> = Transaction.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(key: "date", ascending: true)]
        
        do {
            return try context.fetch(request)
        } catch {
            print("Core Data fetch error: \(error)")
            return []
        }
    }
    
    // MARK: - 특정 날짜 거래 내역 조회
    func fetchTransactions(forDay date: Date) -> [Transaction] {
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
    func fetchTransactions(forMonth date: Date) -> [Transaction] {
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
    
    //MARK: - 연간 거래 내역 조회
    func fetchTransactions(forYear date: Date) -> [Transaction] {
        let year = calendar.component(.year, from: date)
        let start = calendar.date(from: DateComponents(year: year, month: 1, day: 1))!
        let end = calendar.date(from: DateComponents(year: year + 1, month: 1, day: 1))!
        
        let request: NSFetchRequest<Transaction> = Transaction.fetchRequest()
        request.predicate = NSPredicate(format: "date >= %@ AND date < %@", start as NSDate, end as NSDate)
        request.sortDescriptors = [NSSortDescriptor(key: "date", ascending: true)]
        
        do {
            return try context.fetch(request)
        } catch {
            print("Core Data fetch error: \(error)")
            return []
        }
    }
    
    //MARK: - 사용자 설정 기간 거래 내역 조회
    func fetchTransactions(startDate: Date, endDate: Date) -> [Transaction] {
        let request: NSFetchRequest<Transaction> = Transaction.fetchRequest()
        request.predicate = NSPredicate(format: "date >= %@ AND date < %@", startDate as NSDate, endDate as NSDate)
        request.sortDescriptors = [NSSortDescriptor(key: "date", ascending: true)]
        
        do {
            return try context.fetch(request)
        } catch {
            print("Core Data fetch error: \(error)")
            return []
        }
    }
    
    func seedDefaultAssetItemIfNeeded() {
        let request: NSFetchRequest<CashItem> = CashItem.fetchRequest()
        request.fetchLimit = 1
        
        do {
            let count = try context.count(for: request)
            if count == 0 {
                let cashAsset = CashItem(context: context)
                cashAsset.id = UUID()
                cashAsset.name = "현금"
                cashAsset.colorIndexValue = 0
                cashAsset.transactions = nil
                cashAsset.typeValue = 0
                
                let deleted = DeletedItem(context: context)
                deleted.id = UUID()
                deleted.name = "삭제된 자산"
                deleted.typeValue = 4
                
                saveContext()
                print("기본 자산 로드 완료!")
                
            } else {
                print("이미 기본 자산이 존재합니다.")
            }
        } catch {
            print("자산 개수 확인 중 에러 발생: \(error)")
        }
    }
    
    func fetchAssetItems() -> [AssetItem] {
        let request: NSFetchRequest<AssetItem> = AssetItem.fetchRequest()
        return (try? context.fetch(request)) ?? []
    }
    
    func fetchInstallments() -> [Installment] {
        let request: NSFetchRequest<Installment> = Installment.fetchRequest()
        return (try? context.fetch(request)) ?? []
    }

}
