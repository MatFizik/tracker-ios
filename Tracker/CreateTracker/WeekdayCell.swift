//
//  WeekdayCell.swift
//  Tracker
//
//  Created by Adilkhan on 07/11/26.
//

import UIKit

final class WeekdayCell: UITableViewCell {
    static let reuseIdentifier = "WeekdayCell"

    var onToggle: ((Bool) -> Void)?

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 17)
        label.textColor = .blackDay
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let daySwitch: UISwitch = {
        let daySwitch = UISwitch()
        daySwitch.onTintColor = UIColor.ypBlue
        return daySwitch
    }()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        backgroundColor = .backgroundDay
        selectionStyle = .none
        accessoryView = daySwitch
        daySwitch.addTarget(self, action: #selector(didToggleSwitch), for: .valueChanged)

        contentView.addSubview(titleLabel)
        NSLayoutConstraint.activate([
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            titleLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor)
        ])
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        nil
    }

    func configure(day: Weekday, isOn: Bool) {
        titleLabel.text = day.fullName
        daySwitch.isOn = isOn
    }

    @objc private func didToggleSwitch() {
        onToggle?(daySwitch.isOn)
    }
}
