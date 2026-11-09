//
//  TrackerCategoryStore.swift
//  Tracker
//
//  Created by Adilkhan on 07/11/26.
//

import CoreData

protocol TrackerCategoryStoreDelegate: AnyObject {
    func trackerCategoryStoreDidUpdate(_ store: TrackerCategoryStore)
}

// Доступ к сущности TrackerCategoryCD. Наружу отдаёт только структуры TrackerCategory.
// Изменения в категориях отслеживает NSFetchedResultsController и сообщает о них делегату.
final class TrackerCategoryStore: NSObject {
    weak var delegate: TrackerCategoryStoreDelegate?

    private let context: NSManagedObjectContext
    private let fetchedResultsController: NSFetchedResultsController<TrackerCategoryCD>

    convenience init(coreDataStack: CoreDataStack) {
        self.init(context: coreDataStack.context)
    }

    init(context: NSManagedObjectContext) {
        self.context = context

        let fetchRequest: NSFetchRequest<TrackerCategoryCD> = TrackerCategoryCD.fetchRequest()
        fetchRequest.sortDescriptors = [
            NSSortDescriptor(key: #keyPath(TrackerCategoryCD.title), ascending: true)
        ]
        fetchedResultsController = NSFetchedResultsController(
            fetchRequest: fetchRequest,
            managedObjectContext: context,
            sectionNameKeyPath: nil,
            cacheName: nil
        )
        super.init()

        fetchedResultsController.delegate = self
        do {
            try fetchedResultsController.performFetch()
        } catch {
            print("Не удалось загрузить категории: \(error)")
        }
    }

    var categories: [TrackerCategory] {
        fetchedResultsController.fetchedObjects?.compactMap(makeCategory) ?? []
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

// MARK: - NSFetchedResultsControllerDelegate

extension TrackerCategoryStore: NSFetchedResultsControllerDelegate {
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        delegate?.trackerCategoryStoreDidUpdate(self)
    }
}
