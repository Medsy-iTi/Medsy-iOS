//
//  ContentView.swift
//  Medsy-Pharmacy
//
//  Created by Ahmed Elkady on 16/07/2026.
//

import SwiftUI

struct ContentView: View {
    let onboardingFactory: PharmacyOnboardingFactory
    let authenticationFactory: PharmacyAuthenticationFactory
    let homeFactory: PharmacyHomeFactory
    let ordersFactory: PharmacyOrdersFactory
	let completedOrdersFactory: PharmacyCompletedOrdersFactory
    @ObservedObject private var appSettings = PharmacyAppSettings.shared
    @Bindable var coordinator: RootCoordinator

    init(
        onboardingFactory: PharmacyOnboardingFactory,
        authenticationFactory: PharmacyAuthenticationFactory,
        homeFactory: PharmacyHomeFactory,
        ordersFactory: PharmacyOrdersFactory,
	    completedOrdersFactory: PharmacyCompletedOrdersFactory,
        coordinator: RootCoordinator
    ) {
        self.onboardingFactory = onboardingFactory
        self.authenticationFactory = authenticationFactory
        self.homeFactory = homeFactory
        self.ordersFactory = ordersFactory
		self.completedOrdersFactory = completedOrdersFactory
        self.coordinator = coordinator
    }

    var body: some View {
        Group {
            switch coordinator.flow {
            case .splash:
                SplashView {
                    coordinator.finishSplash()
                }
                .transition(.opacity)

            case .onboarding:
                onboardingFactory.makeCoordinator(onComplete: coordinator.finishOnboarding)
                    .makeView()
                .transition(.asymmetric(
                    insertion: .opacity.combined(with: .move(edge: .trailing)),
                    removal: .opacity
                ))

            case .authentication:
                PharmacyAuthenticationRootView(
                    factory: authenticationFactory,
                    shouldResumeStoredSession: coordinator.isAuthenticated,
                    onAuthenticated: coordinator.finishAuthentication,
                    onSignedOut: coordinator.returnToSignIn
                )
                .transition(.opacity)

            case .main:
                PharmacyMainTabView(
                    coordinator: coordinator.mainTabCoordinator,
                    homeFactory: homeFactory,
                    ordersFactory: ordersFactory,
					completedOrdersFactory: completedOrdersFactory,
                    onLoggedOut: coordinator.logout
                )
                .transition(.opacity.combined(with: .move(edge: .trailing)))
            }
        }
        .animation(.easeInOut(duration: 0.45), value: coordinator.flow)
        .preferredColorScheme(appSettings.isDarkMode ? .dark : .light)
    }
}

private struct PharmacyAuthenticationRootView: View {
    @State private var coordinator: PharmacyAuthenticationCoordinator
	@State private var hasAttemptedSessionResume = false
	private let shouldResumeStoredSession: Bool


    init(
        factory: PharmacyAuthenticationFactory,
		shouldResumeStoredSession: Bool,
		onAuthenticated: @escaping () -> Void,
		onSignedOut: @escaping () -> Void
    ) {
		self.shouldResumeStoredSession = shouldResumeStoredSession
		_coordinator = State(
			initialValue: factory.makeCoordinator(
				onAuthenticated: onAuthenticated,
				onSignedOut: onSignedOut
			)
		)
    }

	var body: some View {
		PharmacyAuthenticationCoordinatorView(coordinator: coordinator)
			.task {
				guard shouldResumeStoredSession, !hasAttemptedSessionResume else { return }
				hasAttemptedSessionResume = true
				coordinator.resolveAuthenticatedDestination()
			}
	}
}

#Preview {
	ContentView(
		onboardingFactory: PharmacyOnboardingFactory(getPagesUseCase: GetOnboardingPagesUseCase(repository: OnboardingRepository())),
		authenticationFactory: PharmacyAuthenticationFactory(
			actions: .placeholder,
			locationProvider: PreviewContentLocationProvider()
		),
		homeFactory: PharmacyHomeFactory(
			getProfileUseCase: PreviewGetProfileUseCase(),
			fetchDashboardUseCase: PreviewFetchDashboardUseCase(),
			sendHeartbeatUseCase: PreviewSendHeartbeatUseCase(),
			sessionSettings: PharmacySessionSettings()
		),
		ordersFactory: PharmacyOrdersFactory(
			fetchOrdersUseCase: PreviewFetchOrdersUseCase(),
			getProfileUseCase: PreviewGetProfileUseCase(),
			appSettings: .shared,
			identityProvider: PreviewIdentityProvider()
		),
		completedOrdersFactory: PharmacyCompletedOrdersFactory(
			getCompletedOrdersUseCase: PreviewGetCompletedOrdersUseCase(),
			identityProvider: PreviewIdentityProvider()
															  ),
		coordinator: RootCoordinator(container: PharmacyDIContainer())
	)
	.environment(LanguageManager.shared)
}

private struct PreviewFetchOrdersUseCase: FetchPharmacyOrdersUseCaseProtocol {
	func execute(pharmacyId: Int, page: Int, size: Int) async throws -> PharmacyOrdersPage {
		PharmacyOrdersPage(orders: [], pageNumber: 0, totalPages: 1, isLastPage: true)
	}
}

private struct PreviewFetchDashboardUseCase: FetchPharmacyDashboardUseCaseProtocol {
	func execute(period: PharmacyDashboardPeriod) async throws -> PharmacyDashboard {
		PharmacyDashboard(
			totalRevenue: 0,
			totalOrders: 0,
			requestsReceived: 0,
			offersCreated: 0,
			topSellingProducts: [],
			recentOrders: []
		)
	}
}

private struct PreviewSendHeartbeatUseCase: SendHeartbeatUseCaseProtocol {
	func execute() async throws -> PresenceEntity {
		PresenceEntity(lastHeartbeatAt: "", onDuty: false)
	}
}

private struct PreviewGetProfileUseCase: GetPharmacyProfileUseCaseProtocol {
	func execute() async throws -> PharmacyProfile {
		.preview
	}
}

private final class PreviewIdentityProvider: PharmacyIdentityProviding {
	var currentPharmacyId: Int? = 1
}




@MainActor
private final class PreviewContentLocationProvider: PharmacyLocationProviding {
	func currentLocation() async throws -> PharmacyLocation {
		PharmacyLocation(latitude: 30.0444, longitude: 31.2357, city: "Cairo", province: "Cairo")
	}

	func location(latitude: Double, longitude: Double) async throws -> PharmacyLocation {
		PharmacyLocation(latitude: latitude, longitude: longitude, city: "Cairo", province: "Cairo")
	}
}


private struct PreviewGetCompletedOrdersUseCase: GetCompletedOrdersUseCaseProtocol {
	func execute(pharmacyId: Int, page: Int, size: Int, sort: [String]) async throws -> PaginatedResult<CompletedOrder> {
		.empty
	}
}
