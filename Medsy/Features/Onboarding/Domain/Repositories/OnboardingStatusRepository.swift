//
//  OnboardingStatusRepository.swift
//  Medsy
//
//  Created by Ehab Salah on 15/07/2026.
//

protocol OnboardingStatusRepository {
    var hasCompletedOnboarding: Bool { get }

    func markOnboardingCompleted()
}
