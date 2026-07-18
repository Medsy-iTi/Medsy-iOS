//
//  PharmacyRegistrationAccountView.swift
//  Medsy-Pharmacy
//
//  Created by Ahmed Elkady on 17/07/2026.
//

import SwiftUI

struct PharmacyRegistrationAccountView: View {
    @Bindable var viewModel: PharmacyRegistrationViewModel
    let onRegister: () -> Void

    var body: some View {
        PharmacyAuthScreenContainer {
            PharmacyRegistrationProgressView(currentStep: 2, totalSteps: 2)

            PharmacyAuthHeader(
                title: "pharmacy.auth.account_setup.title".localized,
                subtitle: "pharmacy.auth.account_setup.subtitle".localized,
                systemImage: "person.crop.circle.badge.checkmark"
            )

            VStack(spacing: PharmacySpacing.sm) {
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
                title: "pharmacy.auth.register".localized,
                isLoading: viewModel.isLoading,
                action: onRegister
            )
        }
        .navigationTitle("pharmacy.auth.account_setup.title".localized)
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(viewModel.isLoading)
    }
}
