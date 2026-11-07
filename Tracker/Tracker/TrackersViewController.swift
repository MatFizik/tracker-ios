//
//  TrackerViewController.swift
//  Tracker
//
//  Created by Adilkhan on 10/10/26.
//

import UIKit

final class TrackersViewController: UIViewController {
    private var categories: [TrackerCategory] = []
    private var completedTrackers: [TrackerRecord] = []
    private var currentDate = Date()

    private let searchField: UISearchTextField = {
        let field = UISearchTextField()
        field.placeholder = "Поиск"
        field.translatesAutoresizingMaskIntoConstraints = false
        return field
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
    }
    
    private func addTracker(_ tracker: Tracker, toCategory title: String) {
        if categories.contains(where: {$0.title == title}) {
            categories = categories.map {
                $0.title == title ? TrackerCategory(title: $0.title, trackers: $0.trackers + [tracker]) : $0
            }
        } else {
                categories = categories + [TrackerCategory(title: title, trackers: [tracker])]
            }
        }
    
    private func toggleCompletion(of trackerId: UUID) {
        let calendar = Calendar.current
        if completedTrackers.contains(where: { $0.trackerId == trackerId && calendar.isDate($0.date, inSameDayAs: currentDate) }) {
            completedTrackers.removeAll { $0.trackerId == trackerId && calendar.isDate($0.date, inSameDayAs: currentDate) }
        } else {
            completedTrackers.append(TrackerRecord(trackerId: trackerId, date: currentDate))
        }
    }

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
        view.addSubviews([searchField, emptyStateView])

        NSLayoutConstraint.activate([
            searchField.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 7),
            searchField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            searchField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            searchField.heightAnchor.constraint(equalToConstant: 36),

            emptyStateView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            emptyStateView.centerYAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerYAnchor),
            emptyStateView.leadingAnchor.constraint(greaterThanOrEqualTo: view.leadingAnchor, constant: 16),
            emptyStateView.trailingAnchor.constraint(lessThanOrEqualTo: view.trailingAnchor, constant: -16)
        ])

        updateEmptyState(isEmpty: true)
    }

    private func updateEmptyState(isEmpty: Bool) {
        emptyStateView.isHidden = !isEmpty
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
        print(sender.date)
    }
}
