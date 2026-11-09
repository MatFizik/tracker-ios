//
//  TrackerStore.swift
//  Tracker
//
//  Created by Adilkhan on 07/11/26.
//

import CoreData
import UIKit

protocol TrackerStoreDelegate: AnyObject {
    func trackerStoreDidUpdate(_ store: TrackerStore)
}

final class TrackerStore: NSObject {
    weak var delegate: TrackerStoreDelegate?

    private let context: NSManagedObjectContext
    private let categoryStore: TrackerCategoryStore
    private let fetchedResultsController: NSFetchedResultsController<TrackerCD>

    convenience init(coreDataStack: CoreDataStack, categoryStore: TrackerCategoryStore) {
        self.init(context: coreDataStack.context, categoryStore: categoryStore)
    }

    init(context: NSManagedObjectContext, categoryStore: TrackerCategoryStore) {
        self.context = context
        self.categoryStore = categoryStore

        let fetchRequest: NSFetchRequest<TrackerCD> = TrackerCD.fetchRequest()
        // Первая сортировка должна совпадать с sectionNameKeyPath
        fetchRequest.sortDescriptors = [
            NSSortDescriptor(key: #keyPath(TrackerCD.category.title), ascending: true),
            NSSortDescriptor(key: #keyPath(TrackerCD.name), ascending: true)
        ]
        fetchedResultsController = NSFetchedResultsController(
            fetchRequest: fetchRequest,
            managedObjectContext: context,
            sectionNameKeyPath: #keyPath(TrackerCD.category.title),
            cacheName: nil
        )
        super.init()

        fetchedResultsController.delegate = self
        do {
            try fetchedResultsController.performFetch()
        } catch {
            print("Не удалось загрузить трекеры: \(error)")
        }
    }

    // Секции контроллера — это категории, объекты внутри секции — трекеры этой категории
    var categories: [TrackerCategory] {
        guard let sections = fetchedResultsController.sections else { return [] }

        return sections.compactMap { section in
            let trackersCoreData = section.objects as? [TrackerCD] ?? []
            let trackers = trackersCoreData.compactMap { $0.toTracker() }
            guard !trackers.isEmpty else { return nil }
            return TrackerCategory(title: section.name, trackers: trackers)
        }
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

    private func saveContext() throws {
        do {
            try context.save()
        } catch {
            context.rollback()
            throw error
        }
    }
}

// MARK: - NSFetchedResultsControllerDelegate

extension TrackerStore: NSFetchedResultsControllerDelegate {
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        delegate?.trackerStoreDidUpdate(self)
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
