//
//  UITableViewCell+GroupedStyle.swift
//  Tracker
//
//  Created by Adilkhan on 07/11/26.
//

import UIKit

extension UITableViewCell {
    func applyGroupedStyle(at indexPath: IndexPath, in tableView: UITableView) {
        let rowsCount = tableView.numberOfRows(inSection: indexPath.section)
        let isFirst = indexPath.row == 0
        let isLast = indexPath.row == rowsCount - 1

        var corners: CACornerMask = []
        if isFirst {
            corners.formUnion([.layerMinXMinYCorner, .layerMaxXMinYCorner])
        }
        if isLast {
            corners.formUnion([.layerMinXMaxYCorner, .layerMaxXMaxYCorner])
        }
        layer.masksToBounds = true
        layer.cornerRadius = corners.isEmpty ? 0 : 16
        layer.maskedCorners = corners

        separatorInset = isLast
            ? UIEdgeInsets(top: 0, left: 0, bottom: 0, right: tableView.bounds.width)
            : UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
    }
}
