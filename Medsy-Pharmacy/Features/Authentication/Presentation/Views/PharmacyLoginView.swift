//  PharmacyLoginView.swift
//  Medsy
//
//  Created by Antoneos Philip on 17/07/2026.

import SwiftUI

struct PharmacyLoginView: View {
    @State private var viewModel = PharmacyLoginViewModel()
 

    var body: some View {
        PharmacyAuthScreenContainer {
            PharmacyAuthHeader(
                title: "auth.login.title".localized,
                subtitle: "auth.login.subtitle".localized,
                showsBrand: true
            )

            VStack(spacing: 12) {
                PharmacyCustomTextField(title: "auth.email".localized, type: .email, text: $viewModel.email)
                PharmacyCustomTextField(title: "auth.password".localized, type: .password, text: $viewModel.password)
            }

            HStack {
                Spacer()
                Button("auth.forgot_password".localized) {}
                    .font(.footnote.weight(.semibold))
                    .foregroundStyle(PharmacyColor.primary)
            }

            PharmacyAuthValidationMessage(message: viewModel.validationMessage)

            PharmacyPrimaryButton(
                title: "auth.login.action".localized,
                isLoading: viewModel.isLoading,
                isDisabled: viewModel.isLoading
            ) {
                Task {
                    if await viewModel.submit() {
                    }
                }
            }

            PharmacyAuthDivider()

            VStack(spacing: 12) {
                PharmacyAuthSecondaryButton(title: "auth.continue_google".localized, imageName: "google") {}
                PharmacyAuthSecondaryButton(title: "auth.continue_apple".localized, imageName: "apple") {}
            }

            PharmacyAuthPrompt(
                leadingText: "auth.no_account".localized,
                actionTitle: "auth.signup.link".localized,
            )
        }
        .navigationBarBackButtonHidden()
        .alert(
            "common.error".localized,
            isPresented: Binding(
                get: { viewModel.alertMessage != nil },
                set: { isPresented in
                    if !isPresented {
                        viewModel.dismissError()
                    }
                }
            ),
            actions: {
                Button("common.ok".localized) {
                    viewModel.dismissError()
                }
            },
            message: {
                if let message = viewModel.alertMessage {
                    Text(message)
                }
            }
        )
    }
}
