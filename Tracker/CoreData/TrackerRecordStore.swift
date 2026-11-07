//
//  TrackerRecordStore.swift
//  Tracker
//
//  Created by Adilkhan on 07/11/26.
//

import CoreData

// Доступ к сущности TrackerRecordCD. Наружу отдаёт и принимает только структуры TrackerRecord.
final class TrackerRecordStore {
    private let context: NSManagedObjectContext
    private let trackerStore: TrackerStore

    convenience init(coreDataStack: CoreDataStack) {
        self.init(context: coreDataStack.context)
    }

    init(context: NSManagedObjectContext) {
        self.context = context
        self.trackerStore = TrackerStore(context: context)
    }

    func fetchRecords() throws -> Set<TrackerRecord> {
        let request: NSFetchRequest<TrackerRecordCD> = TrackerRecordCD.fetchRequest()
        let records = try context.fetch(request).compactMap { recordCoreData -> TrackerRecord? in
            guard
                let date = recordCoreData.date,
                let trackerId = recordCoreData.tracker?.id
            else { return nil }
            return TrackerRecord(trackerId: trackerId, date: date)
        }
        return Set(records)
    }

    func addRecord(_ record: TrackerRecord) throws {
        guard let trackerCoreData = try trackerStore.trackerCoreData(withId: record.trackerId) else { return }

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

    private func saveContext() throws {
        do {
            try context.save()
        } catch {
            context.rollback()
            throw error
        }
    }
}
