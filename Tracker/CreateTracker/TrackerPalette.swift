//
//  TrackerPalette.swift
//  Tracker
//
//  Created by Adilkhan on 07/11/26.
//

import UIKit

// Эмодзи и цвета для выбора на экране создания трекера
enum TrackerPalette {
    static let emojis = [
        "🙂", "😻", "🌺", "🐶", "❤️", "😱",
        "😇", "😡", "🥶", "🤔", "🙌", "🍔",
        "🥦", "🏓", "🥇", "🎸", "🏝", "😪"
    ]

    static let colors: [UIColor] = [
        "#FD4C49", "#FF881E", "#007BFA", "#6E44FE", "#33CF69", "#E66DD4",
        "#F9D4D4", "#34A7FE", "#46E69D", "#35347C", "#FF674D", "#FF99CC",
        "#F6C48B", "#7994F5", "#832CF1", "#AD56DA", "#8D72E6", "#2FD058"
    ].map(UIColor.init(hex:))
}
