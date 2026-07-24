//
//  OnboardingViewModel.swift
//  Medsy-Pharmacy
//
//

import Observation

@Observable
@MainActor
final class OnboardingViewModel {
    private(set) var pages: [OnboardingPage]
    var currentIndex: Int = 0

    private let onComplete: () -> Void

    init(getPagesUseCase: GetOnboardingPagesUseCaseProtocol, onComplete: @escaping () -> Void) {
        self.pages = getPagesUseCase.execute()
        self.onComplete = onComplete
    }

    var isLastPage: Bool {
        currentIndex >= pages.count - 1
    }

    func advance() {
        guard !isLastPage else {
            finish()
            return
        }
        currentIndex += 1
    }

    func skip() {
        finish()
    }

    private func finish() {
        onComplete()
    }
}
