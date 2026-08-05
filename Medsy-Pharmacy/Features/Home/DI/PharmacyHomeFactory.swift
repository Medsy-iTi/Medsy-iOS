//
//  PharmacyHomeFactory.swift
//  Medsy-Pharmacy
//
//  Created by Ehab Salah on 20/07/2026.
//

import SwiftUI

struct PharmacyHomeFactory {
    private let getProfileUseCase: GetPharmacyProfileUseCaseProtocol
    private let fetchDashboardUseCase: FetchPharmacyDashboardUseCaseProtocol
    let sessionSettings: PharmacySessionSettings

    init(
        getProfileUseCase: GetPharmacyProfileUseCaseProtocol,
        fetchDashboardUseCase: FetchPharmacyDashboardUseCaseProtocol,
        sessionSettings: PharmacySessionSettings
    ) {
        self.getProfileUseCase = getProfileUseCase
        self.fetchDashboardUseCase = fetchDashboardUseCase
        self.sessionSettings = sessionSettings
    }

    @MainActor
    func makeViewModel() -> PharmacyHomeViewModel {
        PharmacyHomeViewModel(
            getProfileUseCase: getProfileUseCase,
            fetchDashboardUseCase: fetchDashboardUseCase,
            sessionSettings: sessionSettings
        )
    }

    @MainActor
    func makeView(
        viewModel: PharmacyHomeViewModel,
        onSelectRecentOrder: @escaping (Int) -> Void,
        onViewAllCompletedOrders: @escaping () -> Void
    ) -> PharmacyHomeView {
        PharmacyHomeView(
            viewModel: viewModel,
            sessionSettings: sessionSettings,
            onSelectRecentOrder: onSelectRecentOrder,
            onViewAllCompletedOrders: onViewAllCompletedOrders
        )
    }
}
