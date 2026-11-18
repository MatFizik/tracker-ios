import UIKit

final class NewHabitViewModel {

    var onStateChanged: (() -> Void)?
    var onTrackerCreated: ((Tracker, String) -> Void)?

    let emojis = TrackerPalette.emojis
    let colors = TrackerPalette.colors

    private(set) var categoryTitle: String?
    private(set) var selectedEmojiIndex: Int?
    private(set) var selectedColorIndex: Int?

    var scheduleText: String? {
        schedule.isEmpty ? nil : schedule.scheduleText
    }

    var isCreateEnabled: Bool {
        !trimmedName.isEmpty
            && categoryTitle != nil
            && !schedule.isEmpty
            && selectedEmojiIndex != nil
            && selectedColorIndex != nil
    }

    private let categoryStore: TrackerCategoryStore
    private var name = ""
    private var schedule: Set<Weekday> = []

    private var trimmedName: String {
        name.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    init(categoryStore: TrackerCategoryStore) {
        self.categoryStore = categoryStore
    }

    func didChangeName(_ name: String) {
        self.name = name
        onStateChanged?()
    }

    func didSelectEmoji(at index: Int) {
        selectedEmojiIndex = index
        onStateChanged?()
    }

    func didSelectColor(at index: Int) {
        selectedColorIndex = index
        onStateChanged?()
    }

    func makeCategoryListViewModel() -> CategoryListViewModel {
        let viewModel = CategoryListViewModel(categoryStore: categoryStore, selectedCategoryTitle: categoryTitle)
        viewModel.onCategorySelected = { [weak self] title in
            self?.categoryTitle = title
            self?.onStateChanged?()
        }
        return viewModel
    }

    func makeScheduleViewModel() -> ScheduleViewModel {
        let viewModel = ScheduleViewModel(selectedDays: schedule)
        viewModel.onDone = { [weak self] days in
            self?.schedule = days
            self?.onStateChanged?()
        }
        return viewModel
    }

    func createTracker() {
        guard
            isCreateEnabled,
            let categoryTitle,
            let emojiIndex = selectedEmojiIndex,
            let colorIndex = selectedColorIndex
        else { return }

        let tracker = Tracker(
            id: UUID(),
            name: trimmedName,
            color: colors[colorIndex],
            emoji: emojis[emojiIndex],
            schedule: schedule
        )
        onTrackerCreated?(tracker, categoryTitle)
    }
}
