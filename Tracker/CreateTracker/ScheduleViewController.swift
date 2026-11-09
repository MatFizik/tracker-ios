//
//  ScheduleViewController.swift
//  Tracker
//
//  Created by Adilkhan on 07/11/26.
//

import UIKit

final class ScheduleViewController: UIViewController {
    var onDone: ((Set<Weekday>) -> Void)?

    private var selectedDays: Set<Weekday>

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Расписание"
        label.font = .systemFont(ofSize: 16, weight: .medium)
        label.textColor = .blackDay
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private lazy var tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .plain)
        tableView.register(WeekdayCell.self, forCellReuseIdentifier: WeekdayCell.reuseIdentifier)
        tableView.dataSource = self
        tableView.delegate = self
        tableView.rowHeight = 75
        tableView.backgroundColor = .clear
        tableView.separatorColor = UIColor.ypGray
        tableView.tableFooterView = UIView()
        tableView.sectionHeaderTopPadding = 0
        tableView.showsVerticalScrollIndicator = false
        tableView.translatesAutoresizingMaskIntoConstraints = false
        return tableView
    }()

    private let doneButton = ActionButton(title: "Готово", style: .primary)

    init(selectedDays: Set<Weekday>) {
        self.selectedDays = selectedDays
        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        nil
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        doneButton.addTarget(self, action: #selector(didTapDone), for: .touchUpInside)
        setupLayout()
    }

    private func setupLayout() {
        view.addSubviews([titleLabel, tableView, doneButton])

        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: view.topAnchor, constant: 27),
            titleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),

            tableView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 30),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            tableView.bottomAnchor.constraint(equalTo: doneButton.topAnchor, constant: -16),

            doneButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            doneButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            doneButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            doneButton.heightAnchor.constraint(equalToConstant: 60)
        ])
    }

    @objc private func didTapDone() {
        onDone?(selectedDays)
        dismiss(animated: true)
    }
}

// MARK: - UITableViewDataSource

extension ScheduleViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        Weekday.allCases.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: WeekdayCell.reuseIdentifier,
            for: indexPath
        ) as? WeekdayCell else {
            return UITableViewCell()
        }

        let day = Weekday.allCases[indexPath.row]
        cell.configure(day: day, isOn: selectedDays.contains(day))
        cell.onToggle = { [weak self] isOn in
            if isOn {
                self?.selectedDays.insert(day)
            } else {
                self?.selectedDays.remove(day)
            }
        }
        return cell
    }
}

// MARK: - UITableViewDelegate

extension ScheduleViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cell.applyGroupedStyle(at: indexPath, in: tableView)
    }
}
