//
//  ColorCell.swift
//  Tracker
//
//  Created by Adilkhan on 07/11/26.
//

import UIKit

final class ColorCell: UICollectionViewCell {
    static let reuseIdentifier = "ColorCell"

    private let colorView: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 8
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.layer.cornerRadius = 8
        contentView.addSubview(colorView)

        NSLayoutConstraint.activate([
            colorView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            colorView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            colorView.widthAnchor.constraint(equalToConstant: 40),
            colorView.heightAnchor.constraint(equalToConstant: 40)
        ])
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        nil
    }

    func configure(color: UIColor, isSelected: Bool) {
        colorView.backgroundColor = color
        contentView.layer.borderWidth = isSelected ? 3 : 0
        contentView.layer.borderColor = color.withAlphaComponent(0.3).cgColor
    }
}
