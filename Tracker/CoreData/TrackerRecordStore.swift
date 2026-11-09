//
//  TrackerRecordStore.swift
//  Tracker
//
//  Created by Adilkhan on 07/11/26.
//

import CoreData

protocol TrackerRecordStoreDelegate: AnyObject {
    func trackerRecordStoreDidUpdate(_ store: TrackerRecordStore)
}

// Доступ к сущности TrackerRecordCD. Наружу отдаёт и принимает только структуры TrackerRecord.
// Изменения в отметках отслеживает NSFetchedResultsController и сообщает о них делегату.
final class TrackerRecordStore: NSObject {
    weak var delegate: TrackerRecordStoreDelegate?

    private let context: NSManagedObjectContext
    private let fetchedResultsController: NSFetchedResultsController<TrackerRecordCD>

    convenience init(coreDataStack: CoreDataStack) {
        self.init(context: coreDataStack.context)
    }

    init(context: NSManagedObjectContext) {
        self.context = context

        let fetchRequest: NSFetchRequest<TrackerRecordCD> = TrackerRecordCD.fetchRequest()
        fetchRequest.sortDescriptors = [
            NSSortDescriptor(key: #keyPath(TrackerRecordCD.date), ascending: true)
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
            print("Не удалось загрузить отметки: \(error)")
        }
    }

    var records: Set<TrackerRecord> {
        let records = fetchedResultsController.fetchedObjects?.compactMap { recordCoreData -> TrackerRecord? in
            guard
                let date = recordCoreData.date,
                let trackerId = recordCoreData.tracker?.id
            else { return nil }
            return TrackerRecord(trackerId: trackerId, date: date)
        }
        return Set(records ?? [])
    }

    func addRecord(_ record: TrackerRecord) throws {
        guard let trackerCoreData = try trackerCoreData(withId: record.trackerId) else { return }

        let recordCoreData = TrackerRecordCD(context: context)
        recordCoreData.date = record.date
        recordCoreData.tracker = trackerCoreData
        try saveContext()
    }

    func deleteRecord(_ record: TrackerRecord) throws {
        let request: NSFetchRequest<TrackerRecordCD> = TrackerRecordCD.fetchRequest()
        request.predicate = NSPredicate(
            format: "tracker.id == %@ AND %K == %@",
            record.trackerId as CVarArg,
            #keyPath(TrackerRecordCD.date), record.date as NSDate
        )

        try context.fetch(request).forEach { context.delete($0) }
        try saveContext()
    }

    // Находит трекер, к которому нужно привязать запись
    private func trackerCoreData(withId id: UUID) throws -> TrackerCD? {
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

// MARK: - NSFetchedResultsControllerDelegate

extension TrackerRecordStore: NSFetchedResultsControllerDelegate {
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        delegate?.trackerRecordStoreDidUpdate(self)
    }
}
