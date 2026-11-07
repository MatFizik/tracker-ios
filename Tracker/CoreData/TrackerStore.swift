//
//  TrackerStore.swift
//  Tracker
//
//  Created by Adilkhan on 07/11/26.
//

import CoreData
import UIKit

// Доступ к сущности TrackerCD. Наружу отдаёт и принимает только структуры Tracker.
final class TrackerStore {
    private let context: NSManagedObjectContext
    private let categoryStore: TrackerCategoryStore

    convenience init(coreDataStack: CoreDataStack) {
        self.init(context: coreDataStack.context)
    }

    init(context: NSManagedObjectContext) {
        self.context = context
        self.categoryStore = TrackerCategoryStore(context: context)
    }

    func addNewTracker(_ tracker: Tracker, toCategoryWithTitle categoryTitle: String) throws {
        let trackerCoreData = TrackerCD(context: context)
        trackerCoreData.id = tracker.id
        trackerCoreData.name = tracker.name
        trackerCoreData.emoji = tracker.emoji
        trackerCoreData.colorHex = tracker.color.hexString
        trackerCoreData.schedule = tracker.schedule.storageString
        trackerCoreData.category = try categoryStore.categoryCoreData(withTitle: categoryTitle)
        try saveContext()
    }

    // Находит трекер по id. Используется TrackerRecordStore, чтобы привязать запись к трекеру.
    func trackerCoreData(withId id: UUID) throws -> TrackerCD? {
        let request: NSFetchRequest<TrackerCD> = TrackerCD.fetchRequest()
        request.predicate = NSPredicate(format: "id == %@", id as CVarArg)
        request.fetchLimit = 1
        return try context.fetch(request).first
    }

    private func saveContext() throws {
        do {
            try context.save()
        } catch {
            context.rollback()
            throw error
        }
    }
}

// MARK: - Перевод TrackerCD → Tracker

extension TrackerCD {
    func toTracker() -> Tracker? {
        guard
            let id,
            let name,
            let emoji,
            let colorHex,
            let schedule
        else { return nil }

        return Tracker(
            id: id,
            name: name,
            color: UIColor(hex: colorHex),
            emoji: emoji,
            schedule: Set<Weekday>(storageString: schedule)
        )
    }
}

// MARK: - Хранение расписания строкой "2,4,6"

private extension Set where Element == Weekday {
    var storageString: String {
        map(\.rawValue)
            .sorted()
            .map(String.init)
            .joined(separator: ",")
    }

    init(storageString: String) {
        let days = storageString
            .split(separator: ",")
            .compactMap { Int($0) }
            .compactMap(Weekday.init(rawValue:))
        self.init(days)
    }
}
