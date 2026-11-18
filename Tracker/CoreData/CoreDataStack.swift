//
//  CoreDataStack.swift
//  Tracker
//
//  Created by Adilkhan on 07/11/26.
//

import CoreData

final class CoreDataStack {

    // MARK: - Properties

    let persistentContainer: NSPersistentContainer

    var context: NSManagedObjectContext {
        persistentContainer.viewContext
    }

    // MARK: - Initialization

    init(modelName: String = "Tracker") {
        persistentContainer = NSPersistentContainer(name: modelName)
        persistentContainer.loadPersistentStores { _, error in
            if let error = error as NSError? {
                assertionFailure("Не удалось загрузить хранилище Core Data: \(error), \(error.userInfo)")
            }
        }
        persistentContainer.viewContext.automaticallyMergesChangesFromParent = true
    }

    // MARK: - Public Methods

    func saveContext() {
        guard context.hasChanges else { return }
        do {
            try context.save()
        } catch {
            context.rollback()
            assertionFailure("Не удалось сохранить контекст Core Data: \(error)")
        }
    }
}
