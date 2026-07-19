//
//  RootCoordinator.swift
//  Medsy-Pharmacy
//
//  Core/Navigation
//

import Observation

@Observable
@MainActor
final class RootCoordinator {
    private(set) var flow: RootFlow = .splash
    
    private let hasCompletedOnboardingUseCase: HasCompletedOnboardingUseCaseProtocol
    private let completeOnboardingUseCase: CompleteOnboardingUseCaseProtocol
    private let tokenStore: TokenStoreProtocol
    
    var isAuthenticated: Bool

    init(container: PharmacyDIContainer) {
        self.hasCompletedOnboardingUseCase = container.resolve(HasCompletedOnboardingUseCaseProtocol.self)
        self.completeOnboardingUseCase = container.resolve(CompleteOnboardingUseCaseProtocol.self)
        self.tokenStore = container.resolve(TokenStoreProtocol.self)
        self.isAuthenticated = self.tokenStore.accessToken()?.isEmpty == false
    }

    func finishSplash() {
        guard hasCompletedOnboardingUseCase.execute() else {
            try? tokenStore.clearTokens()
            isAuthenticated = false
            flow = .onboarding
            return
        }

        refreshAuthenticationState()
        flow = isAuthenticated ? .main : .authentication
    }

    func finishOnboarding() {
        completeOnboardingUseCase.execute()
        flow = .authentication
    }

    func finishAuthentication() {
        refreshAuthenticationState()
        if isAuthenticated {
            flow = .main
        }
    }

    func logout() {
        try? tokenStore.clearTokens()
        isAuthenticated = false
        flow = .authentication
    }

    private func refreshAuthenticationState() {
        isAuthenticated = tokenStore.accessToken()?.isEmpty == false
    }
}
