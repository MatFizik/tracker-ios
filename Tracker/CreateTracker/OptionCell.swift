//
//  OptionCell.swift
//  Tracker
//
//  Created by Adilkhan on 07/11/26.
//

import UIKit

final class OptionCell: UITableViewCell {
    static let reuseIdentifier = "OptionCell"

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 17)
        label.textColor = .blackDay
        return label
    }()

    private let subtitleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 17)
        label.textColor = UIColor.ypGray
        return label
    }()

    private lazy var labelsStack: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [titleLabel, subtitleLabel])
        stack.axis = .vertical
        stack.spacing = 2
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        backgroundColor = .backgroundDay
        accessoryType = .disclosureIndicator

        contentView.addSubview(labelsStack)
        NSLayoutConstraint.activate([
            labelsStack.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            labelsStack.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            labelsStack.centerYAnchor.constraint(equalTo: contentView.centerYAnchor)
        ])
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        nil
    }

    func configure(title: String, subtitle: String?) {
        titleLabel.text = title
        subtitleLabel.text = subtitle
        subtitleLabel.isHidden = subtitle?.isEmpty ?? true
    }
}
