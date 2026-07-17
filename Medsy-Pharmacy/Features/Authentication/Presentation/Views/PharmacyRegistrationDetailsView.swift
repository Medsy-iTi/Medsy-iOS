//
//  PharmacyRegistrationDetailsView.swift
//  Medsy-Pharmacy
//
//  Created by Ahmed Elkady on 17/07/2026.
//

import SwiftUI

struct PharmacyRegistrationDetailsView: View {
    @Bindable var viewModel: PharmacyRegistrationViewModel
    let onContinue: () -> Void

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
                    text: $viewModel.firstName
                )

                PharmacyAuthTextField(
                    title: "pharmacy.auth.last_name".localized,
                    kind: .name,
                    text: $viewModel.lastName
                )

                PharmacyAuthTextField(
                    title: "pharmacy.auth.phone".localized,
                    kind: .phone,
                    text: $viewModel.phoneNumber
                )

                PharmacyAuthTextField(
                    title: "pharmacy.auth.email".localized,
                    kind: .email,
                    text: $viewModel.email
                )

                PharmacyAuthTextField(
                    title: "pharmacy.auth.home_address".localized,
                    kind: .address,
                    text: $viewModel.homeAddress
                )

                PharmacyAuthDatePicker(dateOfBirth: $viewModel.dateOfBirth)

                PharmacyAuthTextField(
                    title: "pharmacy.auth.password".localized,
                    kind: .password,
                    text: $viewModel.password
                )

                PharmacyAuthTextField(
                    title: "pharmacy.auth.confirm_password".localized,
                    kind: .confirmPassword,
                    text: $viewModel.confirmedPassword
                )
            }

            PharmacyAuthValidationMessage(message: viewModel.validationMessage)

            PharmacyPrimaryButton(
                title: "pharmacy.auth.continue".localized,
                systemImage: "chevron.forward",
                action: onContinue
            )

        }
        .navigationTitle("pharmacy.auth.registration.title".localized)
        .navigationBarTitleDisplayMode(.inline)
    }
}
