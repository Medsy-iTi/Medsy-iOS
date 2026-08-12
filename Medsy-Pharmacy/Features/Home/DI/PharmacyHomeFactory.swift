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
    private let sendHeartbeatUseCase: SendHeartbeatUseCaseProtocol
    let sessionSettings: PharmacySessionSettings

    init(
        getProfileUseCase: GetPharmacyProfileUseCaseProtocol,
        fetchDashboardUseCase: FetchPharmacyDashboardUseCaseProtocol,
        sendHeartbeatUseCase: SendHeartbeatUseCaseProtocol,
        sessionSettings: PharmacySessionSettings
    ) {
        self.getProfileUseCase = getProfileUseCase
        self.fetchDashboardUseCase = fetchDashboardUseCase
        self.sendHeartbeatUseCase = sendHeartbeatUseCase
        self.sessionSettings = sessionSettings
    }

    @MainActor
    func makeViewModel() -> PharmacyHomeViewModel {
        PharmacyHomeViewModel(
            getProfileUseCase: getProfileUseCase,
            fetchDashboardUseCase: fetchDashboardUseCase,
            sendHeartbeatUseCase: sendHeartbeatUseCase,
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
