//
//  UserDefaultsOnboardingStatusRepository.swift
//  Medsy
//
//  Created by Ehab Salah on 15/07/2026.
//

import Foundation

final class UserDefaultsOnboardingStatusRepository: OnboardingStatusRepository {
    private enum Keys {
        static let hasCompletedOnboarding = "onboarding.hasCompleted"
    }

    private let userDefaults: UserDefaults

    init(userDefaults: UserDefaults = .standard) {
        self.userDefaults = userDefaults
    }

    var hasCompletedOnboarding: Bool {
        userDefaults.bool(forKey: Keys.hasCompletedOnboarding)
    }

    func markOnboardingCompleted() {
        userDefaults.set(true, forKey: Keys.hasCompletedOnboarding)
    }
}
