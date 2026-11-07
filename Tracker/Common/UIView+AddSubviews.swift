//
//  UIView+AddSubviews.swift
//  Tracker
//
//  Created by Adilkhan on 07/11/26.
//

import UIKit

extension UIView {
    func addSubviews(_ subviews: [UIView]) {
        subviews.forEach { addSubview($0) }
    }
}
