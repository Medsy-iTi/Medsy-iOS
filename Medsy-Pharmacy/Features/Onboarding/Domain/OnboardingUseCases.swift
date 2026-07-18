//
//  OnboardingUseCases.swift
//  Medsy-Pharmacy
//
//

import Foundation

protocol GetOnboardingPagesUseCaseProtocol {
    func execute() -> [OnboardingPage]
}

struct GetOnboardingPagesUseCase: GetOnboardingPagesUseCaseProtocol {
    let repository: OnboardingRepositoryProtocol

    func execute() -> [OnboardingPage] {
        repository.fetchPages()
    }
}

protocol CompleteOnboardingUseCaseProtocol {
    func execute()
}

struct CompleteOnboardingUseCase: CompleteOnboardingUseCaseProtocol {
    let statusStore: OnboardingStatusStoring

    func execute() {
        statusStore.markOnboardingCompleted()
    }
}

protocol HasCompletedOnboardingUseCaseProtocol {
    func execute() -> Bool
}

struct HasCompletedOnboardingUseCase: HasCompletedOnboardingUseCaseProtocol {
    let statusStore: OnboardingStatusStoring

    func execute() -> Bool {
        statusStore.hasCompletedOnboarding()
    }
}
