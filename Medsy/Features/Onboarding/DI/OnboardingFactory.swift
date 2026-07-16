//
//  OnboardingFactory.swift
//  Medsy
//
//  Created by Ehab Salah on 15/07/2026.
//

import SwiftUI

struct OnboardingFactory {
    private let shouldShowOnboarding: ShouldShowOnboardingUseCase
    private let completeOnboarding: CompleteOnboardingUseCase

    init(
        shouldShowOnboarding: ShouldShowOnboardingUseCase,
        completeOnboarding: CompleteOnboardingUseCase
    ) {
        self.shouldShowOnboarding = shouldShowOnboarding
        self.completeOnboarding = completeOnboarding
    }

    func shouldShow() -> Bool {
        shouldShowOnboarding()
    }

    @MainActor
    func makeView(onComplete: @escaping () -> Void) -> OnboardingView {
        OnboardingView(
            viewModel: OnboardingViewModel(
                completeOnboarding: completeOnboarding,
                onComplete: onComplete
            )
        )
    }
}
