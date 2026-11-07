//
//  Weekday+Names.swift
//  Tracker
//
//  Created by Adilkhan on 07/11/26.
//

extension Weekday {
    var fullName: String {
        switch self {
        case .monday: "Понедельник"
        case .tuesday: "Вторник"
        case .wednesday: "Среда"
        case .thursday: "Четверг"
        case .friday: "Пятница"
        case .saturday: "Суббота"
        case .sunday: "Воскресенье"
        }
    }

    var shortName: String {
        switch self {
        case .monday: "Пн"
        case .tuesday: "Вт"
        case .wednesday: "Ср"
        case .thursday: "Чт"
        case .friday: "Пт"
        case .saturday: "Сб"
        case .sunday: "Вс"
        }
    }
}

extension Set where Element == Weekday {
    var scheduleText: String {
        if count == Weekday.allCases.count {
            return "Каждый день"
        }
        return Weekday.allCases
            .filter { contains($0) }
            .map(\.shortName)
            .joined(separator: ", ")
    }
}
