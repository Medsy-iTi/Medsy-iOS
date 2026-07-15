//
//  AuthenticationFactory.swift
//  Medsy
//

import SwiftUI

/// Composition boundary for the authentication presentation flow.
/// Future login and registration use cases are injected here.
struct AuthenticationFactory {
    @MainActor
    func makeView() -> AuthenticationFlowView {
        AuthenticationFlowView()
    }
}
