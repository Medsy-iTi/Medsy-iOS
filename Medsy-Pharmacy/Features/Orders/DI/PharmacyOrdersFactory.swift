//
//  PharmacyOrdersFactory.swift
//  Medsy-Pharmacy
//
//  Created by Ehab Salah on 20/07/2026.
//

import SwiftUI

struct PharmacyOrdersFactory {
	private let fetchOrdersUseCase: FetchPharmacyOrdersUseCaseProtocol
	private let getProfileUseCase: GetPharmacyProfileUseCaseProtocol
	private let appSettings: PharmacyAppSettings
	private let identityProvider: PharmacyIdentityProviding

	init(
		fetchOrdersUseCase: FetchPharmacyOrdersUseCaseProtocol,
		getProfileUseCase: GetPharmacyProfileUseCaseProtocol,
		appSettings: PharmacyAppSettings ,
	    identityProvider: PharmacyIdentityProviding
	) {
		self.fetchOrdersUseCase = fetchOrdersUseCase
		self.getProfileUseCase = getProfileUseCase
		self.appSettings = appSettings
		self.identityProvider = identityProvider

	}

	@MainActor
	func makeCoordinator() -> PharmacyOrdersCoordinator {
		PharmacyOrdersCoordinator(
			fetchOrdersUseCase: fetchOrdersUseCase,
			getProfileUseCase: getProfileUseCase,
			appSettings: appSettings,
			identityProvider: identityProvider
		)
	}
}
