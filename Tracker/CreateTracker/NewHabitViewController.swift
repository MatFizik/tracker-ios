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
            case .category: "Категория"
            case .schedule: "Расписание"
            }
        }
    }

    private enum Layout {
        static let cellSize: CGFloat = 52
        static let itemsPerRow = 6
        static let collectionSideInset: CGFloat = 18

        static func collectionHeight(itemsCount: Int) -> CGFloat {
            let rows = (itemsCount + itemsPerRow - 1) / itemsPerRow
            return CGFloat(rows) * cellSize
        }
    }

    private let categoryTitle: String
    private var schedule: Set<Weekday> = [] {
        didSet {
            tableView.reloadData()
            updateCreateButtonState()
        }
    }
    private var selectedEmojiIndex: Int? {
        didSet { updateCreateButtonState() }
    }
    private var selectedColorIndex: Int? {
        didSet { updateCreateButtonState() }
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

    private let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.keyboardDismissMode = .onDrag
        scrollView.showsVerticalScrollIndicator = false
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        return scrollView
    }()

    private let contentView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
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

    private let emojiTitleLabel = NewHabitViewController.makeSectionTitle("Emoji")
    private let colorTitleLabel = NewHabitViewController.makeSectionTitle("Цвет")

    private lazy var emojiCollectionView: UICollectionView = {
        let collectionView = makeCollectionView()
        collectionView.register(EmojiCell.self, forCellWithReuseIdentifier: EmojiCell.reuseIdentifier)
        return collectionView
    }()

    private lazy var colorCollectionView: UICollectionView = {
        let collectionView = makeCollectionView()
        collectionView.register(ColorCell.self, forCellWithReuseIdentifier: ColorCell.reuseIdentifier)
        return collectionView
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

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        nil
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        setupActions()
        setupLayout()
        updateCreateButtonState()
    }

    // MARK: - Setup

    private static func makeSectionTitle(_ text: String) -> UILabel {
        let label = UILabel()
        label.text = text
        label.font = .systemFont(ofSize: 19, weight: .bold)
        label.textColor = .blackDay
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }

    private func makeCollectionView() -> UICollectionView {
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())
        collectionView.backgroundColor = .clear
        collectionView.isScrollEnabled = false
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        return collectionView
    }

    private func setupActions() {
        nameField.delegate = self
        nameField.addTarget(self, action: #selector(didChangeName), for: .editingChanged)
        cancelButton.addTarget(self, action: #selector(didTapCancel), for: .touchUpInside)
        createButton.addTarget(self, action: #selector(didTapCreate), for: .touchUpInside)

        let tap = UITapGestureRecognizer(target: self, action: #selector(hideKeyboard))
        tap.cancelsTouchesInView = false
        tap.delegate = self
        view.addGestureRecognizer(tap)
    }

    private func setupLayout() {
        view.addSubviews([titleLabel, scrollView])
        scrollView.addSubview(contentView)
        contentView.addSubviews([
            nameField,
            tableView,
            emojiTitleLabel,
            emojiCollectionView,
            colorTitleLabel,
            colorCollectionView,
            buttonsStack
        ])

        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: view.topAnchor, constant: 27),
            titleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),

            scrollView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 14),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.keyboardLayoutGuide.topAnchor),

            contentView.topAnchor.constraint(equalTo: scrollView.contentLayoutGuide.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.contentLayoutGuide.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.frameLayoutGuide.widthAnchor),

            nameField.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 24),
            nameField.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            nameField.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            nameField.heightAnchor.constraint(equalToConstant: 75),

            tableView.topAnchor.constraint(equalTo: nameField.bottomAnchor, constant: 24),
            tableView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            tableView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            tableView.heightAnchor.constraint(equalToConstant: 75 * CGFloat(Option.allCases.count)),

            emojiTitleLabel.topAnchor.constraint(equalTo: tableView.bottomAnchor, constant: 28),
            emojiTitleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 28),

            emojiCollectionView.topAnchor.constraint(equalTo: emojiTitleLabel.bottomAnchor, constant: 24),
            emojiCollectionView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            emojiCollectionView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            emojiCollectionView.heightAnchor.constraint(
                equalToConstant: Layout.collectionHeight(itemsCount: TrackerPalette.emojis.count)
            ),

            colorTitleLabel.topAnchor.constraint(equalTo: emojiCollectionView.bottomAnchor, constant: 36),
            colorTitleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 28),

            colorCollectionView.topAnchor.constraint(equalTo: colorTitleLabel.bottomAnchor, constant: 24),
            colorCollectionView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            colorCollectionView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            colorCollectionView.heightAnchor.constraint(
                equalToConstant: Layout.collectionHeight(itemsCount: TrackerPalette.colors.count)
            ),

            buttonsStack.topAnchor.constraint(equalTo: colorCollectionView.bottomAnchor, constant: 40),
            buttonsStack.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            buttonsStack.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            buttonsStack.heightAnchor.constraint(equalToConstant: 60),
            buttonsStack.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
        ])
    }

    // MARK: - State

    private var trimmedName: String {
        (nameField.text ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
    }

    private func updateCreateButtonState() {
        createButton.isEnabled = !trimmedName.isEmpty
            && !schedule.isEmpty
            && selectedEmojiIndex != nil
            && selectedColorIndex != nil
    }

    private func openSchedule() {
        let scheduleViewController = ScheduleViewController(selectedDays: schedule)
        scheduleViewController.onDone = { [weak self] days in
            self?.schedule = days
        }
        present(scheduleViewController, animated: true)
    }

    // MARK: - Actions

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
        guard
            createButton.isEnabled,
            let emojiIndex = selectedEmojiIndex,
            let colorIndex = selectedColorIndex
        else { return }

        let tracker = Tracker(
            id: UUID(),
            name: trimmedName,
            color: TrackerPalette.colors[colorIndex],
            emoji: TrackerPalette.emojis[emojiIndex],
            schedule: schedule
        )
        delegate?.newHabitViewController(self, didCreate: tracker)
        dismiss(animated: true)
    }
}

// MARK: - UIGestureRecognizerDelegate

extension NewHabitViewController: UIGestureRecognizerDelegate {
    // Тап по кнопке не должен скрывать клавиатуру: иначе кнопки уезжают вниз вместе с ней
    // до того, как сработает нажатие
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        !(touch.view is UIControl)
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

// MARK: - UICollectionViewDataSource

extension NewHabitViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        collectionView === emojiCollectionView ? TrackerPalette.emojis.count : TrackerPalette.colors.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if collectionView === emojiCollectionView {
            guard let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: EmojiCell.reuseIdentifier,
                for: indexPath
            ) as? EmojiCell else {
                return UICollectionViewCell()
            }
            cell.configure(
                emoji: TrackerPalette.emojis[indexPath.item],
                isSelected: indexPath.item == selectedEmojiIndex
            )
            return cell
        }

        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: ColorCell.reuseIdentifier,
            for: indexPath
        ) as? ColorCell else {
            return UICollectionViewCell()
        }
        cell.configure(
            color: TrackerPalette.colors[indexPath.item],
            isSelected: indexPath.item == selectedColorIndex
        )
        return cell
    }
}

// MARK: - UICollectionViewDelegateFlowLayout

extension NewHabitViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if collectionView === emojiCollectionView {
            selectedEmojiIndex = indexPath.item
        } else {
            selectedColorIndex = indexPath.item
        }
        collectionView.reloadData()
    }

    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAt indexPath: IndexPath
    ) -> CGSize {
        CGSize(width: Layout.cellSize, height: Layout.cellSize)
    }

    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        minimumInteritemSpacingForSectionAt section: Int
    ) -> CGFloat {
        // Растягиваем промежутки так, чтобы в ряду всегда было ровно 6 ячеек
        let itemsWidth = Layout.cellSize * CGFloat(Layout.itemsPerRow)
        let freeWidth = collectionView.bounds.width - Layout.collectionSideInset * 2 - itemsWidth
        return max(0, floor(freeWidth / CGFloat(Layout.itemsPerRow - 1)))
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
        UIEdgeInsets(top: 0, left: Layout.collectionSideInset, bottom: 0, right: Layout.collectionSideInset)
    }
}
