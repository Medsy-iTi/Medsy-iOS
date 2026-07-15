//
//  OnboardingViewModel.swift
//  Medsy
//
//  Created by Ehab Salah on 15/07/2026.
//

import Observation

@MainActor
@Observable
final class OnboardingViewModel {
    let pages: [OnboardingPage]
    private(set) var hasFinished = false
    var currentPageIndex = 0

    private let completeOnboarding: CompleteOnboardingUseCase
    private let onComplete: () -> Void

    init(
        pages: [OnboardingPage] = OnboardingPage.pages,
        completeOnboarding: CompleteOnboardingUseCase,
        onComplete: @escaping () -> Void
    ) {
        self.pages = pages
        self.completeOnboarding = completeOnboarding
        self.onComplete = onComplete
    }

    var isLastPage: Bool {
        currentPageIndex == pages.count - 1
    }

    var primaryButtonTitle: String {
        isLastPage ? "onboarding.get_started".localized : "onboarding.next".localized
    }

    func performPrimaryAction() {
        guard !hasFinished else { return }

        if isLastPage {
            finish()
        } else {
            currentPageIndex = min(currentPageIndex + 1, pages.count - 1)
        }
    }

    func skip() {
        finish()
    }

    private func finish() {
        guard !hasFinished else { return }
        hasFinished = true
        completeOnboarding()
        onComplete()
    }
}
