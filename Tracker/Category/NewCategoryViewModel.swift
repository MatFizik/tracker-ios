import Foundation

final class NewCategoryViewModel {

    var onDoneEnabledChanged: ((Bool) -> Void)?
    var onCategoryCreated: ((String) -> Void)?

    var isDoneEnabled: Bool {
        !trimmedName.isEmpty
    }

    private let maxNameLength = 38
    private var name = ""

    private var trimmedName: String {
        name.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    func canChangeName(to text: String) -> Bool {
        text.count <= maxNameLength
    }

    func didChangeName(_ text: String) {
        name = text
        onDoneEnabledChanged?(isDoneEnabled)
    }

    func didTapDone() {
        guard isDoneEnabled else { return }
        onCategoryCreated?(trimmedName)
    }
}
