import Foundation

struct OnboardingPage {
    let imageName: String
    let text: String
}

final class OnboardingViewModel {

    var onFinish: (() -> Void)?

    let pages = [
        OnboardingPage(imageName: "onboarding_blue", text: "Отслеживайте только то, что хотите"),
        OnboardingPage(imageName: "onboarding_red", text: "Даже если это не литры воды и йога")
    ]

    private let storage: OnboardingStorage

    init(storage: OnboardingStorage) {
        self.storage = storage
    }

    func didTapFinish() {
        storage.isOnboardingShown = true
        onFinish?()
    }
}
