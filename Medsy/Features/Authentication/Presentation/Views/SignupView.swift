//
//  SignupView.swift
//  Medsy
//
//  Created by Ehab Salah on 16/07/2026.
//

import SwiftUI

struct SignupView: View {
    @State private var viewModel = SignupViewModel()
    let onLoginTapped: () -> Void
    let onVerificationRequested: (String) -> Void

    var body: some View {
        AuthScreenContainer {
            AuthHeader(
                title: "auth.signup.title".localized,
                subtitle: "auth.signup.subtitle".localized
            )

            VStack(spacing: 12) {
                CustomTextField(title: "auth.first_name".localized, type: .name, text: $viewModel.firstName)
                CustomTextField(title: "auth.last_name".localized, type: .name, text: $viewModel.lastName)
                CustomTextField(title: "auth.phone".localized, type: .phone, text: $viewModel.phoneNumber)
                CustomTextField(title: "auth.email".localized, type: .email, text: $viewModel.email)
                CustomTextField(title: "auth.password".localized, type: .password, text: $viewModel.password)
                CustomTextField(title: "auth.confirm_password".localized, type: .confirmPassword, text: $viewModel.confirmedPassword)
                CustomTextField(title: "auth.home_address".localized, type: .address, text: $viewModel.homeAddress)

                SignupDatePicker(dateOfBirth: $viewModel.dateOfBirth)
            }

            Toggle(isOn: $viewModel.hasAcceptedTerms) {
                HStack(spacing: 4) {
                    Text("auth.terms.prefix".localized)
                    Text("auth.terms".localized)
                        .foregroundStyle(AppColor.green)
                }
                .font(.footnote)
                .foregroundStyle(AppColor.textSec)
            }
            .tint(AppColor.green)

            AuthValidationMessage(message: viewModel.validationMessage)

            PrimaryButton(
                title: "auth.signup.action".localized,
                isDisabled: !viewModel.hasAcceptedTerms
            ) {
                if viewModel.submit() {
                    onVerificationRequested(viewModel.email)
                }
            }

            AuthPrompt(
                leadingText: "auth.has_account".localized,
                actionTitle: "auth.login.link".localized,
                action: onLoginTapped
            )
        }
        .navigationTitle("auth.signup.title".localized)
        .navigationBarTitleDisplayMode(.inline)
    }

}

#Preview {
    NavigationStack {
        SignupView(onLoginTapped: {}, onVerificationRequested: { _ in })
    }
    .environment(LanguageManager.shared)
}
