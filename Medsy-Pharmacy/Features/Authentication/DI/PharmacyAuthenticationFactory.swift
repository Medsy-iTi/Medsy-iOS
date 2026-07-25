//
//  PharmacyAuthenticationFactory.swift
//  Medsy-Pharmacy
//
//  Created by Ahmed Elkady on 17/07/2026.
//

struct PharmacyAuthenticationFactory {
    private let actions: PharmacyAuthenticationActions
    private let locationProvider: PharmacyLocationProviding

    init(
        actions: PharmacyAuthenticationActions,
        locationProvider: PharmacyLocationProviding
    ) {
        self.actions = actions
        self.locationProvider = locationProvider
    }

    @MainActor
    func makeCoordinator(
        onAuthenticated: @escaping () -> Void,
        onSignedOut: @escaping () -> Void = {}
    ) -> PharmacyAuthenticationCoordinator {
        PharmacyAuthenticationCoordinator(
            actions: actions,
            locationProvider: locationProvider,
            onAuthenticated: onAuthenticated,
            onSignedOut: onSignedOut
        )
    }
}
