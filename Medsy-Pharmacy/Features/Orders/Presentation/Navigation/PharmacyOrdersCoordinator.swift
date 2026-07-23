//
//  PharmacyOrdersCoordinator.swift
//  Medsy
//
//  Created by Shahudaa on 22/07/2026.
//


import SwiftUI
import Observation

@Observable
@MainActor
final class PharmacyOrdersCoordinator: Coordinator {
	var path = NavigationPath()

	private let fetchOrdersUseCase: FetchPharmacyOrdersUseCaseProtocol
	private let getProfileUseCase: GetPharmacyProfileUseCaseProtocol
	private let appSettings: PharmacyAppSettings
	let identityProvider: PharmacyIdentityProviding

	init(
		fetchOrdersUseCase: FetchPharmacyOrdersUseCaseProtocol,
		getProfileUseCase: GetPharmacyProfileUseCaseProtocol,
		appSettings: PharmacyAppSettings,
		identityProvider: PharmacyIdentityProviding
	) {
		self.fetchOrdersUseCase = fetchOrdersUseCase
		self.getProfileUseCase = getProfileUseCase
		self.appSettings = appSettings
		self.identityProvider = identityProvider
	}

	@ViewBuilder
	func start() -> some View {
		PharmacyOrdersView(viewModel: makeViewModel(), coordinator: self)
	}

	func makeViewModel() -> PharmacyOrdersViewModel {
		PharmacyOrdersViewModel(
			fetchOrdersUseCase: fetchOrdersUseCase,
			getProfileUseCase: getProfileUseCase,
			appSettings: appSettings,
			identityProvider: identityProvider
		)
	}

	func pop() {
		guard !path.isEmpty else { return }
		path.removeLast()
	}

	func popToRoot() {
		path.removeLast(path.count)
	}


}
