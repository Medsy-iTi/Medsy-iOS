//
//  OnboardingStatusStoring.swift
//  Medsy-Pharmacy
//
//

import Foundation


protocol OnboardingStatusStoring {
    func hasCompletedOnboarding() -> Bool
    func markOnboardingCompleted()
}

final class UserDefaultsOnboardingStatusStore: OnboardingStatusStoring {
    private enum Keys {
        static let completed = "pharmacy_has_completed_onboarding"
    }

    private let defaults: UserDefaults

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
    }

    func hasCompletedOnboarding() -> Bool {
        defaults.bool(forKey: Keys.completed)
    }

    func markOnboardingCompleted() {
        defaults.set(true, forKey: Keys.completed)
    }
}
