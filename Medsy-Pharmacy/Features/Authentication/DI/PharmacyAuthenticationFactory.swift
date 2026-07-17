//
//  PharmacyAuthenticationFactory.swift
//  Medsy-Pharmacy
//
//  Created by Ahmed Elkady on 17/07/2026.
//

struct PharmacyAuthenticationFactory {
    private let actions: PharmacyAuthenticationActions

    init(actions: PharmacyAuthenticationActions) {
        self.actions = actions
    }

    @MainActor
    func makeCoordinator(
        onLoginRequested: @escaping () -> Void,
        onAuthenticated: @escaping () -> Void
    ) -> PharmacyAuthenticationCoordinator {
        PharmacyAuthenticationCoordinator(
            actions: actions,
            onLoginRequested: onLoginRequested,
            onAuthenticated: onAuthenticated
        )
    }
}
