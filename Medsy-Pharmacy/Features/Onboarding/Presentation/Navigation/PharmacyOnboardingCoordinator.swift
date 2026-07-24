//
//  PharmacyOnboardingCoordinator.swift
//  Medsy-Pharmacy
//
//  Features/Onboarding/Presentation/Navigation
//

import Observation
import SwiftUI

@MainActor
@Observable
final class PharmacyOnboardingCoordinator {
    private let viewModel: OnboardingViewModel

    init(viewModel: OnboardingViewModel) {
        self.viewModel = viewModel
    }

    func makeView() -> OnboardingView {
        OnboardingView(viewModel: viewModel)
    }
}
