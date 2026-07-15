//
//  SignupView.swift
//  Medsy
//

import SwiftUI

struct SignupView: View {
    @State private var viewModel = SignupViewModel()
    let onLoginTapped: () -> Void

    var body: some View {
        AuthScreenContainer {
            AuthHeader(
                title: "auth.signup.title".localized,
                subtitle: "auth.signup.subtitle".localized
            )

            VStack(spacing: 12) {
                CustomTextField(title: "auth.full_name".localized, type: .name, text: $viewModel.fullName)
                CustomTextField(title: "auth.phone".localized, type: .phone, text: $viewModel.phoneNumber)
                CustomTextField(title: "auth.email".localized, type: .email, text: $viewModel.email)
                CustomTextField(title: "auth.password".localized, type: .password, text: $viewModel.password)
                CustomTextField(title: "auth.confirm_password".localized, type: .confirmPassword, text: $viewModel.confirmedPassword)
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

            validationMessage

            PrimaryButton(
                title: "auth.signup.action".localized,
                isDisabled: !viewModel.hasAcceptedTerms
            ) {
                viewModel.submit()
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

    @ViewBuilder
    private var validationMessage: some View {
        if let message = viewModel.validationMessage {
            Text(message)
                .font(.footnote)
                .foregroundStyle(.red)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
    }
}

#Preview {
    NavigationStack {
        SignupView(onLoginTapped: {})
    }
    .environment(LanguageManager.shared)
}
