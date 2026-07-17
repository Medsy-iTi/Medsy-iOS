//
//  PharmacyRegistrationFlowView.swift
//  Medsy-Pharmacy
//
//  Created by Ahmed Elkady on 17/07/2026.
//

import SwiftUI

struct PharmacyRegistrationFlowView: View {
    @State private var firstName = ""
    @State private var lastName = ""
    @State private var phoneNumber = ""
    @State private var email = ""
    @State private var password = ""
    @State private var confirmedPassword = ""
    @State private var accountType: PharmacyAccountType?
    @State private var path: [RegistrationRoute] = []
    let onLoginTapped: () -> Void
    let onRegistrationRequested: (PharmacyAccountType, String) -> Void

    var body: some View {
        NavigationStack(path: $path) {
            PharmacyRegistrationDetailsView(
                firstName: $firstName,
                lastName: $lastName,
                phoneNumber: $phoneNumber,
                email: $email,
                password: $password,
                confirmedPassword: $confirmedPassword,
                validationMessage: nil,
                onContinue: { path.append(.accountType) },
                onLoginTapped: onLoginTapped
            )
            .navigationDestination(for: RegistrationRoute.self) { route in
                switch route {
                case .accountType:
                    PharmacyAccountTypeView(
                        selection: $accountType,
                        validationMessage: nil,
                        isLoading: false,
                        onRegister: register
                    )
                }
            }
        }
        .tint(PharmacyColor.primary)
    }

    private func register() {
        guard let accountType else { return }
        onRegistrationRequested(accountType, email)
    }
}

private enum RegistrationRoute: Hashable {
    case accountType
}

#Preview {
    PharmacyRegistrationFlowView(
        onLoginTapped: {},
        onRegistrationRequested: { _, _ in }
    )
    .environment(LanguageManager.shared)
}
