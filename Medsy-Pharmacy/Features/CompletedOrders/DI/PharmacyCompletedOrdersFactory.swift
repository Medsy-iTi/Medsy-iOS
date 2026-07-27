//
//  holding.swift
//  Medsy
//
//  Created by Shahudaa on 26/07/2026.
//



import SwiftUI

struct PharmacyCompletedOrdersFactory {
    let getCompletedOrdersUseCase: GetCompletedOrdersUseCaseProtocol
    let identityProvider: PharmacyIdentityProviding

    @MainActor
    func makeView() -> some View {
        CompletedOrdersTabRootView(factory: self)
    }

    @MainActor
    func makeViewModel(coordinator: CompletedOrdersCoordinatorProtocol) -> CompletedOrdersViewModel {
        CompletedOrdersViewModel(
            pharmacyId: identityProvider.currentPharmacyId ?? 0,
            getCompletedOrdersUseCase: getCompletedOrdersUseCase,
            coordinator: coordinator
        )
    }
}
