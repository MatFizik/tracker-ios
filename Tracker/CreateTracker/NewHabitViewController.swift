//
//  NewHabitViewController.swift
//  Tracker
//
//  Created by Adilkhan on 07/11/26.
//

import UIKit

protocol NewHabitViewControllerDelegate: AnyObject {
    func newHabitViewController(_ controller: NewHabitViewController, didCreate tracker: Tracker)
}

final class NewHabitViewController: UIViewController {
    weak var delegate: NewHabitViewControllerDelegate?

    private enum Option: CaseIterable {
        case category
        case schedule

        var title: String {
            switch self {
            case .category: return "Категория"
            case .schedule: return "Расписание"
            }
        }
    }

    // Выбора эмодзи и цвета в этом спринте нет — берём случайные значения из макета
    private static let emojis = ["🙂", "😻", "🌺", "🐶", "❤️", "😱", "😇", "😡", "🥶", "🤔", "🙌", "🍔", "🥦", "🏓", "🥇", "🎸", "🏝", "😪"]
    private static let colors: [UIColor] = [
        UIColor(red: 253 / 255, green: 76 / 255, blue: 73 / 255, alpha: 1),
        UIColor(red: 255 / 255, green: 136 / 255, blue: 30 / 255, alpha: 1),
        UIColor(red: 0 / 255, green: 123 / 255, blue: 250 / 255, alpha: 1),
        UIColor(red: 110 / 255, green: 68 / 255, blue: 254 / 255, alpha: 1),
        UIColor(red: 51 / 255, green: 207 / 255, blue: 105 / 255, alpha: 1),
        UIColor(red: 230 / 255, green: 109 / 255, blue: 212 / 255, alpha: 1)
    ]

    private let categoryTitle: String
    private var schedule: Set<Weekday> = [] {
        didSet {
            tableView.reloadData()
            updateCreateButtonState()
        }
    }

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Новая привычка"
        label.font = .systemFont(ofSize: 16, weight: .medium)
        label.textColor = .blackDay
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let nameField: UITextField = {
        let field = UITextField()
        field.placeholder = "Введите название трекера"
        field.font = .systemFont(ofSize: 17)
        field.textColor = .blackDay
        field.backgroundColor = .backgroundDay
        field.layer.cornerRadius = 16
        field.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 16, height: 0))
        field.leftViewMode = .always
        field.clearButtonMode = .whileEditing
        field.returnKeyType = .done
        field.translatesAutoresizingMaskIntoConstraints = false
        return field
    }()

    private lazy var tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .plain)
        tableView.register(OptionCell.self, forCellReuseIdentifier: OptionCell.reuseIdentifier)
        tableView.dataSource = self
        tableView.delegate = self
        tableView.rowHeight = 75
        tableView.isScrollEnabled = false
        tableView.backgroundColor = .clear
        tableView.separatorColor = UIColor.ypGray
        tableView.tableFooterView = UIView()
        tableView.sectionHeaderTopPadding = 0
        tableView.translatesAutoresizingMaskIntoConstraints = false
        return tableView
    }()

    private let cancelButton = ActionButton(title: "Отменить", style: .cancel)
    private let createButton = ActionButton(title: "Создать", style: .primary)

    private lazy var buttonsStack: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [cancelButton, createButton])
        stack.axis = .horizontal
        stack.spacing = 8
        stack.distribution = .fillEqually
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()

    init(categoryTitle: String) {
        self.categoryTitle = categoryTitle
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        setupActions()
        setupLayout()
        updateCreateButtonState()
    }

    private func setupActions() {
        nameField.delegate = self
        nameField.addTarget(self, action: #selector(didChangeName), for: .editingChanged)
        cancelButton.addTarget(self, action: #selector(didTapCancel), for: .touchUpInside)
        createButton.addTarget(self, action: #selector(didTapCreate), for: .touchUpInside)

        let tap = UITapGestureRecognizer(target: self, action: #selector(hideKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }

    private func setupLayout() {
        view.addSubviews([titleLabel, nameField, tableView, buttonsStack])

        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: view.topAnchor, constant: 27),
            titleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),

            nameField.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 38),
            nameField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            nameField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            nameField.heightAnchor.constraint(equalToConstant: 75),

            tableView.topAnchor.constraint(equalTo: nameField.bottomAnchor, constant: 24),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            tableView.heightAnchor.constraint(equalToConstant: 75 * CGFloat(Option.allCases.count)),

            buttonsStack.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            buttonsStack.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            buttonsStack.bottomAnchor.constraint(equalTo: view.keyboardLayoutGuide.topAnchor),
            buttonsStack.heightAnchor.constraint(equalToConstant: 60)
        ])
    }

    private var trimmedName: String {
        (nameField.text ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
    }

    private func updateCreateButtonState() {
        createButton.isEnabled = !trimmedName.isEmpty && !schedule.isEmpty
    }

    private func openSchedule() {
        let scheduleViewController = ScheduleViewController(selectedDays: schedule)
        scheduleViewController.onDone = { [weak self] days in
            self?.schedule = days
        }
        present(scheduleViewController, animated: true)
    }

    @objc private func didChangeName() {
        updateCreateButtonState()
    }

    @objc private func hideKeyboard() {
        view.endEditing(true)
    }

    @objc private func didTapCancel() {
        dismiss(animated: true)
    }

    @objc private func didTapCreate() {
        guard createButton.isEnabled else { return }
        let tracker = Tracker(
            id: UUID(),
            name: trimmedName,
            color: Self.colors.randomElement() ?? .systemGreen,
            emoji: Self.emojis.randomElement() ?? "🙂",
            schedule: schedule
        )
        delegate?.newHabitViewController(self, didCreate: tracker)
        dismiss(animated: true)
    }
}

// MARK: - UITextFieldDelegate

extension NewHabitViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }

    func textFieldShouldClear(_ textField: UITextField) -> Bool {
        textField.text = ""
        updateCreateButtonState()
        return false
    }
}

// MARK: - UITableViewDataSource

extension NewHabitViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        Option.allCases.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: OptionCell.reuseIdentifier,
            for: indexPath
        ) as? OptionCell else {
            return UITableViewCell()
        }

        let option = Option.allCases[indexPath.row]
        switch option {
        case .category:
            cell.configure(title: option.title, subtitle: categoryTitle)
        case .schedule:
            cell.configure(title: option.title, subtitle: schedule.isEmpty ? nil : schedule.scheduleText)
        }
        return cell
    }
}

// MARK: - UITableViewDelegate

extension NewHabitViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cell.applyGroupedStyle(at: indexPath, in: tableView)
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        hideKeyboard()

        switch Option.allCases[indexPath.row] {
        case .category:
            break // экран категорий появится в следующих спринтах
        case .schedule:
            openSchedule()
        }
    }
}
