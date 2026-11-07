//
//  Weekday+Names.swift
//  Tracker
//
//  Created by Adilkhan on 07/11/26.
//

extension Weekday {
    var fullName: String {
        switch self {
        case .monday: return "Понедельник"
        case .tuesday: return "Вторник"
        case .wednesday: return "Среда"
        case .thursday: return "Четверг"
        case .friday: return "Пятница"
        case .saturday: return "Суббота"
        case .sunday: return "Воскресенье"
        }
    }

    var shortName: String {
        switch self {
        case .monday: return "Пн"
        case .tuesday: return "Вт"
        case .wednesday: return "Ср"
        case .thursday: return "Чт"
        case .friday: return "Пт"
        case .saturday: return "Сб"
        case .sunday: return "Вс"
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
