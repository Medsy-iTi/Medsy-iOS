//
//  PharmacyLoginView.swift
//  Medsy-Pharmacy
//
//  Created by Antoneos Philip on 17/07/2026.
//

import SwiftUI

struct PharmacyLoginView: View {
    @State private var email = ""
    @State private var password = ""
    @State private var isLoading = false
    @State private var validationMessage: String? = nil

    let onSignupTapped: () -> Void
    let onAuthenticated: () -> Void

    var body: some View {
        PharmacyAuthScreenContainer {
            PharmacyAuthHeader(
                title: "pharmacy.auth.login.title".localized,
                subtitle: "pharmacy.auth.login.subtitle".localized
            )

            VStack(spacing: PharmacySpacing.sm) {
                PharmacyAuthTextField(
                    title: "pharmacy.auth.email".localized,
                    kind: .email,
                    text: $email
                )

                PharmacyAuthTextField(
                    title: "pharmacy.auth.password".localized,
                    kind: .password,
                    text: $password
                )
            }

            HStack {
                Spacer()
                Button("pharmacy.auth.forgot_password".localized) {}
                    .font(PharmacyColor.sans(13, .semibold))
                    .foregroundStyle(PharmacyColor.primary)
            }

            PharmacyAuthValidationMessage(message: validationMessage)

            PharmacyPrimaryButton(
                title: "pharmacy.auth.login.action".localized,
                isLoading: isLoading,
                isDisabled: isLoading
            ) {
                if email.isEmpty || password.isEmpty {
                    validationMessage = "pharmacy.auth.validation.required".localized
                } else if !email.contains("@") {
                    validationMessage = "pharmacy.auth.validation.email".localized
                } else {
                    validationMessage = nil
                    isLoading = true
                    Task {
                        try? await Task.sleep(for: .seconds(1))
                        isLoading = false
                        onAuthenticated()
                    }
                }
            }

            PharmacyAuthDivider()

            VStack(spacing: PharmacySpacing.sm) {
                PharmacyAuthSecondaryButton(
                    title: "pharmacy.auth.continue_google".localized,
                    imageName: "google"
                ) {}

                PharmacyAuthSecondaryButton(
                    title: "pharmacy.auth.continue_apple".localized,
                    imageName: "apple"
                ) {}
            }

            PharmacyAuthPrompt(
                leadingText: "pharmacy.auth.no_account".localized,
                actionTitle: "pharmacy.auth.signup.link".localized,
                action: onSignupTapped
            )
        }
        .navigationBarBackButtonHidden()
    }
}

#Preview {
    PharmacyLoginView(
        onSignupTapped: {},
        onAuthenticated: {}
    )
    .environment(LanguageManager.shared)
}
