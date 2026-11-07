//
//  TrackersViewController.swift
//  Tracker
//
//  Created by Adilkhan on 10/10/26.
//

import UIKit

final class TrackersViewController: UIViewController {
    private enum Layout {
        static let sideInset: CGFloat = 16
        static let interitemSpacing: CGFloat = 9
        static let cellHeight: CGFloat = 148
        static let headerHeight: CGFloat = 46
    }

    private var categories: [TrackerCategory] = []
    private var visibleCategories: [TrackerCategory] = []
    private var completedTrackers: [TrackerRecord] = []
    private var currentDate = Date()

    private let searchField: UISearchTextField = {
        let field = UISearchTextField()
        field.placeholder = "Поиск"
        field.translatesAutoresizingMaskIntoConstraints = false
        return field
    }()

    private lazy var collectionView: UICollectionView = {
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())
        collectionView.backgroundColor = .white
        collectionView.keyboardDismissMode = .onDrag
        collectionView.register(TrackerCell.self, forCellWithReuseIdentifier: TrackerCell.reuseIdentifier)
        collectionView.register(
            TrackerSectionHeader.self,
            forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
            withReuseIdentifier: TrackerSectionHeader.reuseIdentifier
        )
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        return collectionView
    }()

    private let emptyStateView: EmptyStateView = {
        let view = EmptyStateView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        buildAppBar()
        buildView()
        addMockTrackers()
        filterTrackers()
    }

    // MARK: - Data

    private func addTracker(_ tracker: Tracker, toCategory title: String) {
        if categories.contains(where: { $0.title == title }) {
            categories = categories.map {
                $0.title == title ? TrackerCategory(title: $0.title, trackers: $0.trackers + [tracker]) : $0
            }
        } else {
            categories = categories + [TrackerCategory(title: title, trackers: [tracker])]
        }
    }

    private func toggleCompletion(of trackerId: UUID) {
        let calendar = Calendar.current
        if isCompleted(trackerId) {
            completedTrackers.removeAll { $0.trackerId == trackerId && calendar.isDate($0.date, inSameDayAs: currentDate) }
        } else {
            completedTrackers.append(TrackerRecord(trackerId: trackerId, date: currentDate))
        }
    }

    private func isCompleted(_ trackerId: UUID) -> Bool {
        completedTrackers.contains { $0.trackerId == trackerId && Calendar.current.isDate($0.date, inSameDayAs: currentDate) }
    }

    private func completedDays(for trackerId: UUID) -> Int {
        completedTrackers.filter { $0.trackerId == trackerId }.count
    }

    private func isFutureDate(_ date: Date) -> Bool {
        Calendar.current.compare(date, to: Date(), toGranularity: .day) == .orderedDescending
    }

    private func filterTrackers() {
        let weekdayNumber = Calendar.current.component(.weekday, from: currentDate)
        guard let weekday = Weekday(rawValue: weekdayNumber) else { return }
        let searchText = (searchField.text ?? "").trimmingCharacters(in: .whitespaces).lowercased()

        visibleCategories = categories.compactMap { category in
            let trackers = category.trackers.filter { tracker in
                let matchesDate = tracker.schedule.isEmpty || tracker.schedule.contains(weekday)
                let matchesSearch = searchText.isEmpty || tracker.name.lowercased().contains(searchText)
                return matchesDate && matchesSearch
            }
            return trackers.isEmpty ? nil : TrackerCategory(title: category.title, trackers: trackers)
        }

        updateEmptyState(isEmpty: visibleCategories.isEmpty)
        collectionView.reloadData()
    }

    // TODO: удалить, когда появится экран создания трекера
    private func addMockTrackers() {
        addTracker(
            Tracker(
                id: UUID(),
                name: "Поливать растения",
                color: UIColor(red: 51 / 255, green: 207 / 255, blue: 105 / 255, alpha: 1),
                emoji: "❤️",
                schedule: Set(Weekday.allCases)
            ),
            toCategory: "Домашний уют"
        )
        addTracker(
            Tracker(
                id: UUID(),
                name: "Кошка заслонила камеру на созвоне",
                color: UIColor(red: 255 / 255, green: 136 / 255, blue: 30 / 255, alpha: 1),
                emoji: "😻",
                schedule: [.monday, .wednesday, .friday]
            ),
            toCategory: "Радостные мелочи"
        )
        addTracker(
            Tracker(
                id: UUID(),
                name: "Бабушка прислала открытку в вотсапе",
                color: UIColor(red: 253 / 255, green: 76 / 255, blue: 73 / 255, alpha: 1),
                emoji: "🌺",
                schedule: [.saturday, .sunday]
            ),
            toCategory: "Радостные мелочи"
        )
        addTracker(
            Tracker(
                id: UUID(),
                name: "Свидания в апреле",
                color: UIColor(red: 0 / 255, green: 123 / 255, blue: 250 / 255, alpha: 1),
                emoji: "🙂",
                schedule: [.tuesday, .thursday]
            ),
            toCategory: "Радостные мелочи"
        )
    }

    // MARK: - UI

    private func buildAppBar() {
        navigationItem.title = "Трекеры"

        let addButton = UIBarButtonItem(
            image: UIImage(systemName: "plus", withConfiguration: UIImage.SymbolConfiguration(weight: .semibold)),
            style: .plain,
            target: nil,
            action: nil
        )
        addButton.tintColor = .blackDay
        navigationItem.leftBarButtonItem = addButton
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: makeDatePicker())
    }

    private func buildView() {
        searchField.addTarget(self, action: #selector(didChangeSearchText), for: .editingChanged)
        view.addSubviews([searchField, collectionView, emptyStateView])

        NSLayoutConstraint.activate([
            searchField.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 7),
            searchField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            searchField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            searchField.heightAnchor.constraint(equalToConstant: 36),

            collectionView.topAnchor.constraint(equalTo: searchField.bottomAnchor, constant: 10),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),

            emptyStateView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            emptyStateView.centerYAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerYAnchor),
            emptyStateView.leadingAnchor.constraint(greaterThanOrEqualTo: view.leadingAnchor, constant: 16),
            emptyStateView.trailingAnchor.constraint(lessThanOrEqualTo: view.trailingAnchor, constant: -16)
        ])
    }

    private func updateEmptyState(isEmpty: Bool) {
        emptyStateView.isHidden = !isEmpty
        collectionView.isHidden = isEmpty
    }

    private func makeDatePicker() -> UIDatePicker {
        let datePicker = UIDatePicker()
        datePicker.datePickerMode = .date
        datePicker.preferredDatePickerStyle = .compact
        datePicker.locale = Locale(identifier: "ru_RU")
        datePicker.addTarget(self, action: #selector(didChangeDate(_:)), for: .valueChanged)

        return datePicker
    }

    @objc private func didChangeDate(_ sender: UIDatePicker) {
        currentDate = sender.date
        presentedViewController?.dismiss(animated: true)
        filterTrackers()
    }

    @objc private func didChangeSearchText() {
        filterTrackers()
    }
}

// MARK: - UICollectionViewDataSource

extension TrackersViewController: UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        visibleCategories.count
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        visibleCategories[section].trackers.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: TrackerCell.reuseIdentifier,
            for: indexPath
        ) as? TrackerCell else {
            return UICollectionViewCell()
        }

        let tracker = visibleCategories[indexPath.section].trackers[indexPath.item]
        cell.delegate = self
        cell.configure(
            with: tracker,
            isCompleted: isCompleted(tracker.id),
            completedDays: completedDays(for: tracker.id)
        )
        return cell
    }

    func collectionView(
        _ collectionView: UICollectionView,
        viewForSupplementaryElementOfKind kind: String,
        at indexPath: IndexPath
    ) -> UICollectionReusableView {
        guard
            kind == UICollectionView.elementKindSectionHeader,
            let header = collectionView.dequeueReusableSupplementaryView(
                ofKind: kind,
                withReuseIdentifier: TrackerSectionHeader.reuseIdentifier,
                for: indexPath
            ) as? TrackerSectionHeader
        else {
            return UICollectionReusableView()
        }

        header.configure(title: visibleCategories[indexPath.section].title)
        return header
    }
}

// MARK: - UICollectionViewDelegateFlowLayout

extension TrackersViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAt indexPath: IndexPath
    ) -> CGSize {
        let availableWidth = collectionView.bounds.width - Layout.sideInset * 2 - Layout.interitemSpacing
        return CGSize(width: floor(availableWidth / 2), height: Layout.cellHeight)
    }

    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        minimumInteritemSpacingForSectionAt section: Int
    ) -> CGFloat {
        Layout.interitemSpacing
    }

    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        minimumLineSpacingForSectionAt section: Int
    ) -> CGFloat {
        0
    }

    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        insetForSectionAt section: Int
    ) -> UIEdgeInsets {
        UIEdgeInsets(top: 0, left: Layout.sideInset, bottom: 0, right: Layout.sideInset)
    }

    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        referenceSizeForHeaderInSection section: Int
    ) -> CGSize {
        CGSize(width: collectionView.bounds.width, height: Layout.headerHeight)
    }
}

// MARK: - TrackerCellDelegate

extension TrackersViewController: TrackerCellDelegate {
    func trackerCellDidTapDone(_ cell: TrackerCell) {
        guard
            !isFutureDate(currentDate),
            let indexPath = collectionView.indexPath(for: cell)
        else { return }

        let tracker = visibleCategories[indexPath.section].trackers[indexPath.item]
        toggleCompletion(of: tracker.id)
        collectionView.reloadItems(at: [indexPath])
    }
}
