import Foundation

final class OnboardingStorage {

    private let userDefaults: UserDefaults
    private let onboardingShownKey = "isOnboardingShown"

    init(userDefaults: UserDefaults = .standard) {
        self.userDefaults = userDefaults
    }

    var isOnboardingShown: Bool {
        get { userDefaults.bool(forKey: onboardingShownKey) }
        set { userDefaults.set(newValue, forKey: onboardingShownKey) }
    }
}
