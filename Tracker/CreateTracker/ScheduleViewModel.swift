import Foundation

final class ScheduleViewModel {

    var onDone: ((Set<Weekday>) -> Void)?

    let days = Weekday.allCases

    private var selectedDays: Set<Weekday>

    init(selectedDays: Set<Weekday>) {
        self.selectedDays = selectedDays
    }

    func isSelected(_ day: Weekday) -> Bool {
        selectedDays.contains(day)
    }

    func didToggle(_ day: Weekday, isOn: Bool) {
        if isOn {
            selectedDays.insert(day)
        } else {
            selectedDays.remove(day)
        }
    }

    func didTapDone() {
        onDone?(selectedDays)
    }
}
