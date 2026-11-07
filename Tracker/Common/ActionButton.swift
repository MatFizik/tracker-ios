//
//  ActionButton.swift
//  Tracker
//
//  Created by Adilkhan on 07/11/26.
//

import UIKit

final class ActionButton: UIButton {
    enum Style {
        case primary
        case cancel
    }

    private let style: Style

    override var isEnabled: Bool {
        didSet { updateAppearance() }
    }

    init(title: String, style: Style) {
        self.style = style
        super.init(frame: .zero)
        setTitle(title, for: .normal)
        titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
        layer.cornerRadius = 16
        layer.masksToBounds = true
        translatesAutoresizingMaskIntoConstraints = false

        switch style {
        case .primary:
            setTitleColor(.white, for: .normal)
            setTitleColor(.white, for: .disabled)
        case .cancel:
            backgroundColor = .white
            setTitleColor(UIColor.ypRed, for: .normal)
            layer.borderWidth = 1
            layer.borderColor = UIColor.ypRed.cgColor
        }
        updateAppearance()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        nil
    }

    private func updateAppearance() {
        guard style == .primary else { return }
        backgroundColor = isEnabled ? .blackDay : UIColor.ypGray
    }
}
