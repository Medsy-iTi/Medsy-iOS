//
//  PharmacyOnboardingFactory.swift
//  Medsy-Pharmacy
//
//

import SwiftUI

struct PharmacyOnboardingFactory {
    private let getPagesUseCase: GetOnboardingPagesUseCaseProtocol

    init(getPagesUseCase: GetOnboardingPagesUseCaseProtocol) {
        self.getPagesUseCase = getPagesUseCase
    }

    @MainActor
    func makeCoordinator(onComplete: @escaping () -> Void) -> PharmacyOnboardingCoordinator {
        PharmacyOnboardingCoordinator(
            viewModel: OnboardingViewModel(
                getPagesUseCase: getPagesUseCase,
                onComplete: onComplete
            )
        )
    }
}
