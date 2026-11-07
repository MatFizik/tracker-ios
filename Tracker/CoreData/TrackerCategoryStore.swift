//
//  TrackerCategoryStore.swift
//  Tracker
//
//  Created by Adilkhan on 07/11/26.
//

import CoreData

// Доступ к сущности TrackerCategoryCD. Наружу отдаёт только структуры TrackerCategory.
final class TrackerCategoryStore {
    private let context: NSManagedObjectContext

    convenience init(coreDataStack: CoreDataStack) {
        self.init(context: coreDataStack.context)
    }

    init(context: NSManagedObjectContext) {
        self.context = context
    }

    func fetchCategories() throws -> [TrackerCategory] {
        let request: NSFetchRequest<TrackerCategoryCD> = TrackerCategoryCD.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(key: #keyPath(TrackerCategoryCD.title), ascending: true)]
        return try context.fetch(request).compactMap(makeCategory)
    }

    // Находит категорию по названию или создаёт новую. Используется TrackerStore при создании трекера.
    func categoryCoreData(withTitle title: String) throws -> TrackerCategoryCD {
        let request: NSFetchRequest<TrackerCategoryCD> = TrackerCategoryCD.fetchRequest()
        request.predicate = NSPredicate(format: "%K == %@", #keyPath(TrackerCategoryCD.title), title)
        request.fetchLimit = 1

        if let existingCategory = try context.fetch(request).first {
            return existingCategory
        }

        let category = TrackerCategoryCD(context: context)
        category.id = UUID()
        category.title = title
        return category
    }

    private func makeCategory(from categoryCoreData: TrackerCategoryCD) -> TrackerCategory? {
        guard let title = categoryCoreData.title else { return nil }

        let trackersCoreData = categoryCoreData.trackers as? Set<TrackerCD> ?? []
        let trackers = trackersCoreData
            .compactMap { $0.toTracker() }
            .sorted { $0.name < $1.name }
        return TrackerCategory(title: title, trackers: trackers)
    }
}
