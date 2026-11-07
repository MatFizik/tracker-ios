//
//  UIColor+Hex.swift
//  Tracker
//
//  Created by Adilkhan on 07/11/26.
//

import UIKit

extension UIColor {
    // Создаёт цвет из HEX строки
    nonisolated convenience init(hex: String) {
        let cleaned = hex
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .replacingOccurrences(of: "#", with: "")
        var value: UInt64 = 0
        Scanner(string: cleaned).scanHexInt64(&value)

        self.init(
            red: CGFloat((value >> 16) & 0xFF) / 255,
            green: CGFloat((value >> 8) & 0xFF) / 255,
            blue: CGFloat(value & 0xFF) / 255,
            alpha: 1
        )
    }
}
