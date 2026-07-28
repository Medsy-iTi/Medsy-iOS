//
//  PharmacyHomeFactory.swift
//  Medsy-Pharmacy
//
//  Created by Ehab Salah on 20/07/2026.
//

import SwiftUI

struct PharmacyHomeFactory {
    private let getProfileUseCase: GetPharmacyProfileUseCaseProtocol
    private let fetchOrdersUseCase: FetchPharmacyOrdersUseCaseProtocol
    private let identityProvider: PharmacyIdentityProviding
    let sessionSettings: PharmacySessionSettings

    init(
        getProfileUseCase: GetPharmacyProfileUseCaseProtocol,
        fetchOrdersUseCase: FetchPharmacyOrdersUseCaseProtocol,
        identityProvider: PharmacyIdentityProviding,
        sessionSettings: PharmacySessionSettings
    ) {
        self.getProfileUseCase = getProfileUseCase
        self.fetchOrdersUseCase = fetchOrdersUseCase
        self.identityProvider = identityProvider
        self.sessionSettings = sessionSettings
    }

    @MainActor
    func makeViewModel() -> PharmacyHomeViewModel {
        PharmacyHomeViewModel(
            getProfileUseCase: getProfileUseCase,
            fetchOrdersUseCase: fetchOrdersUseCase,
            identityProvider: identityProvider,
            sessionSettings: sessionSettings
        )
    }

    @MainActor
    func makeView(
        viewModel: PharmacyHomeViewModel,
        onViewAllOrders: @escaping () -> Void
    ) -> PharmacyHomeView {
        PharmacyHomeView(
            viewModel: viewModel,
            sessionSettings: sessionSettings,
            onViewAllOrders: onViewAllOrders
        )
    }
}
