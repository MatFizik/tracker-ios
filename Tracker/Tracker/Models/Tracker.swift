//
//  Tracker.swift
//  Tracker
//
//  Created by Adilkhan on 7/11/26.
//

import UIKit

struct Tracker {
    let id: UUID
    let name: String
    let color: UIColor
    let emoji: String
    let schedule: Set<Weekday>
}
