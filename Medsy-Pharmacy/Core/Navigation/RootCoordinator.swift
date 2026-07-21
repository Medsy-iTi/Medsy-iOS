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
    let mainTabCoordinator = PharmacyMainTabCoordinator()
    
    private let hasCompletedOnboardingUseCase: HasCompletedOnboardingUseCaseProtocol
    private let completeOnboardingUseCase: CompleteOnboardingUseCaseProtocol
    private let tokenStore: TokenStoreProtocol
    
    var isAuthenticated: Bool

    init(container: PharmacyDIContainer) {
        self.hasCompletedOnboardingUseCase = container.resolve(HasCompletedOnboardingUseCaseProtocol.self)
        self.completeOnboardingUseCase = container.resolve(CompleteOnboardingUseCaseProtocol.self)
        self.tokenStore = container.resolve(TokenStoreProtocol.self)

        
        let isFreshInstall = !container.resolve(HasCompletedOnboardingUseCaseProtocol.self).execute()
        if isFreshInstall {
            try? container.resolve(TokenStoreProtocol.self).clearTokens()
        }

        self.isAuthenticated = isFreshInstall ? false : (self.tokenStore.accessToken() != nil)
    }

    func finishSplash() {
        if isAuthenticated {
            flow = .main
        } else {
            flow = hasCompletedOnboardingUseCase.execute() ? .authentication : .onboarding
        }
    }

    func finishOnboarding() {
        completeOnboardingUseCase.execute()
        flow = .authentication
    }

    func finishAuthentication() {
        isAuthenticated = true
        flow = .main
    }

    func logout() {
        isAuthenticated = false
        try? tokenStore.clearTokens()
        flow = .authentication
    }
}
