//
//  OnboardingCoordinator.swift
//  Medsy
//
//  Created by Ehab Salah on 16/07/2026.
//

import Observation
import SwiftUI

@MainActor
@Observable
final class OnboardingCoordinator {
    private let viewModel: OnboardingViewModel

    init(viewModel: OnboardingViewModel) {
        self.viewModel = viewModel
    }

    func makeView() -> OnboardingView {
        OnboardingView(viewModel: viewModel)
    }
}
