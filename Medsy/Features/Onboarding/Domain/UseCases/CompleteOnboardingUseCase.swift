//
//  CompleteOnboardingUseCase.swift
//  Medsy
//
//  Created by Ehab Salah on 15/07/2026.
//

struct CompleteOnboardingUseCase {
    private let repository: any OnboardingStatusRepository

    init(repository: any OnboardingStatusRepository) {
        self.repository = repository
    }

    func callAsFunction() {
        repository.markOnboardingCompleted()
    }
}
