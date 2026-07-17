//
//  PharmacyRegistrationDetailsView.swift
//  Medsy-Pharmacy
//
//  Created by Ahmed Elkady on 17/07/2026.
//

import SwiftUI

struct PharmacyRegistrationDetailsView: View {
    @Binding var firstName: String
    @Binding var lastName: String
    @Binding var phoneNumber: String
    @Binding var email: String
    @Binding var password: String
    @Binding var confirmedPassword: String
    let validationMessage: String?
    let onContinue: () -> Void
    let onLoginTapped: () -> Void

    var body: some View {
        PharmacyAuthScreenContainer {
            PharmacyRegistrationProgressView(currentStep: 1, totalSteps: 2)

            PharmacyAuthHeader(
                title: "pharmacy.auth.registration.title".localized,
                subtitle: "pharmacy.auth.registration.details.subtitle".localized
            )

            VStack(spacing: PharmacySpacing.sm) {
                PharmacyAuthTextField(
                    title: "pharmacy.auth.first_name".localized,
                    kind: .name,
                    text: $firstName
                )

                PharmacyAuthTextField(
                    title: "pharmacy.auth.last_name".localized,
                    kind: .name,
                    text: $lastName
                )

                PharmacyAuthTextField(
                    title: "pharmacy.auth.phone".localized,
                    kind: .phone,
                    text: $phoneNumber
                )

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

                PharmacyAuthTextField(
                    title: "pharmacy.auth.confirm_password".localized,
                    kind: .confirmPassword,
                    text: $confirmedPassword
                )
            }

            PharmacyAuthValidationMessage(message: validationMessage)

            PharmacyPrimaryButton(
                title: "pharmacy.auth.continue".localized,
                systemImage: "chevron.forward",
                action: onContinue
            )

            PharmacyAuthPrompt(
                leadingText: "pharmacy.auth.has_account".localized,
                actionTitle: "pharmacy.auth.login".localized,
                action: onLoginTapped
            )
        }
        .navigationTitle("pharmacy.auth.registration.title".localized)
        .navigationBarTitleDisplayMode(.inline)
    }
}
