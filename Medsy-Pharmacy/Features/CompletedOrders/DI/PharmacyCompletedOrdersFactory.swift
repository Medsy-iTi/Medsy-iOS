//
//  holding.swift
//  Medsy
//
//  Created by Shahudaa on 26/07/2026.
//



import SwiftUI

struct PharmacyCompletedOrdersFactory {
    let getCompletedOrdersUseCase: GetCompletedOrdersUseCaseProtocol
    let getProfileUseCase: GetPharmacyProfileUseCaseProtocol
    let identityProvider: PharmacyIdentityProviding

    @MainActor
    func makeView() -> some View {
        CompletedOrdersTabRootView(factory: self)
    }

    @MainActor
    func makeViewModel(coordinator: CompletedOrdersCoordinatorProtocol) -> CompletedOrdersViewModel {
        CompletedOrdersViewModel(
            getCompletedOrdersUseCase: getCompletedOrdersUseCase,
            getProfileUseCase: getProfileUseCase,
            identityProvider: identityProvider,
            coordinator: coordinator
        )
    }
}
