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
	private(set) var mainTabCoordinator = PharmacyMainTabCoordinator()

	private let hasCompletedOnboardingUseCase: HasCompletedOnboardingUseCaseProtocol
	private let completeOnboardingUseCase: CompleteOnboardingUseCaseProtocol
	private let tokenStore: TokenStoreProtocol
	private let pharmacySession: PharmacySessionSettings

	var isAuthenticated: Bool

	init(container: PharmacyDIContainer) {
		self.hasCompletedOnboardingUseCase = container.resolve(HasCompletedOnboardingUseCaseProtocol.self)
		self.completeOnboardingUseCase = container.resolve(CompleteOnboardingUseCaseProtocol.self)
		self.tokenStore = container.resolve(TokenStoreProtocol.self)
		self.pharmacySession = container.resolve(PharmacySessionSettings.self)


		let isFreshInstall = !container.resolve(HasCompletedOnboardingUseCaseProtocol.self).execute()
		if isFreshInstall {
			try? container.resolve(TokenStoreProtocol.self).clearTokens()
			self.pharmacySession.clear()
		}

		self.isAuthenticated = isFreshInstall ? false : (self.tokenStore.accessToken() != nil)
	}

	func finishSplash() {
		flow = hasCompletedOnboardingUseCase.execute() ? .authentication : .onboarding
	}

	func finishOnboarding() {
		completeOnboardingUseCase.execute()
		flow = .authentication
	}

	func finishAuthentication() {
		isAuthenticated = true
		mainTabCoordinator = PharmacyMainTabCoordinator()
		flow = .main
	}

	func logout() {
		isAuthenticated = false
		try? tokenStore.clearTokens()
		pharmacySession.clear()
		mainTabCoordinator.select(.home)
		flow = .authentication
	}

	func returnToSignIn() {
		isAuthenticated = false
		try? tokenStore.clearTokens()
		pharmacySession.clear()
		mainTabCoordinator.select(.home)
		flow = .authentication
	}
}
