import UIKit

struct TrackerCellViewModel {
    let tracker: Tracker
    let isCompleted: Bool
    let completedDays: Int
}

final class TrackersViewModel {

    var onTrackersChanged: (() -> Void)?

    private(set) var visibleCategories: [TrackerCategory] = []

    var isEmpty: Bool {
        visibleCategories.isEmpty
    }

    private let coreDataStack: CoreDataStack
    private let trackerStore: TrackerStore
    private let categoryStore: TrackerCategoryStore
    private let recordStore: TrackerRecordStore

    private var categories: [TrackerCategory] = []
    private var completedTrackers: Set<TrackerRecord> = []
    private var currentDate = Date()
    private var searchText = ""

    init(coreDataStack: CoreDataStack) {
        let categoryStore = TrackerCategoryStore(coreDataStack: coreDataStack)
        self.coreDataStack = coreDataStack
        self.categoryStore = categoryStore
        self.trackerStore = TrackerStore(coreDataStack: coreDataStack, categoryStore: categoryStore)
        self.recordStore = TrackerRecordStore(coreDataStack: coreDataStack)

        trackerStore.delegate = self
        categoryStore.delegate = self
        recordStore.delegate = self
        reloadFromStores()
    }

    func numberOfTrackers(inSection section: Int) -> Int {
        visibleCategories[section].trackers.count
    }

    func sectionTitle(at section: Int) -> String {
        visibleCategories[section].title
    }

    func cellViewModel(at indexPath: IndexPath) -> TrackerCellViewModel {
        let tracker = visibleCategories[indexPath.section].trackers[indexPath.item]
        return TrackerCellViewModel(
            tracker: tracker,
            isCompleted: completedTrackers.contains(makeRecord(for: tracker.id)),
            completedDays: completedTrackers.filter { $0.trackerId == tracker.id }.count
        )
    }

    func didChangeDate(_ date: Date) {
        currentDate = date
        filterTrackers()
    }

    func didChangeSearchText(_ text: String) {
        searchText = text
        filterTrackers()
    }

    func didTapDone(at indexPath: IndexPath) {
        guard !isFutureDate(currentDate) else { return }
        let tracker = visibleCategories[indexPath.section].trackers[indexPath.item]
        toggleCompletion(of: tracker.id)
    }

    func makeNewHabitViewModel() -> NewHabitViewModel {
        let viewModel = NewHabitViewModel(categoryStore: TrackerCategoryStore(coreDataStack: coreDataStack))
        viewModel.onTrackerCreated = { [weak self] tracker, categoryTitle in
            self?.addTracker(tracker, toCategory: categoryTitle)
        }
        return viewModel
    }

    private func reloadFromStores() {
        categories = trackerStore.categories
        completedTrackers = recordStore.records
        filterTrackers()
    }

    private func filterTrackers() {
        let weekdayNumber = Calendar.current.component(.weekday, from: currentDate)
        guard let weekday = Weekday(rawValue: weekdayNumber) else { return }
        let query = searchText.trimmingCharacters(in: .whitespaces).lowercased()

        visibleCategories = categories.compactMap { category in
            let trackers = category.trackers.filter { tracker in
                let matchesDate = tracker.schedule.contains(weekday)
                let matchesSearch = query.isEmpty || tracker.name.lowercased().contains(query)
                return matchesDate && matchesSearch
            }
            return trackers.isEmpty ? nil : TrackerCategory(title: category.title, trackers: trackers)
        }

        onTrackersChanged?()
    }

    private func addTracker(_ tracker: Tracker, toCategory title: String) {
        do {
            try trackerStore.addNewTracker(tracker, toCategoryWithTitle: title)
        } catch {
            print("Не удалось сохранить трекер: \(error)")
        }
    }

    private func toggleCompletion(of trackerId: UUID) {
        let record = makeRecord(for: trackerId)
        do {
            if completedTrackers.contains(record) {
                try recordStore.deleteRecord(record)
            } else {
                try recordStore.addRecord(record)
            }
        } catch {
            print("Не удалось обновить отметку: \(error)")
        }
    }

    private func makeRecord(for trackerId: UUID) -> TrackerRecord {
        TrackerRecord(trackerId: trackerId, date: Calendar.current.startOfDay(for: currentDate))
    }

    private func isFutureDate(_ date: Date) -> Bool {
        Calendar.current.compare(date, to: Date(), toGranularity: .day) == .orderedDescending
    }
}

extension TrackersViewModel: TrackerStoreDelegate {
    func trackerStoreDidUpdate(_ store: TrackerStore) {
        reloadFromStores()
    }
}

extension TrackersViewModel: TrackerCategoryStoreDelegate {
    func trackerCategoryStoreDidUpdate(_ store: TrackerCategoryStore) {
        reloadFromStores()
    }
}

extension TrackersViewModel: TrackerRecordStoreDelegate {
    func trackerRecordStoreDidUpdate(_ store: TrackerRecordStore) {
        reloadFromStores()
    }
}
