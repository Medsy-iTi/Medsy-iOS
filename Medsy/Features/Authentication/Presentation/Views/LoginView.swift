//
//  LoginView.swift
//  Medsy
//

import SwiftUI

struct LoginView: View {
    @State private var viewModel = LoginViewModel()
    let onSignupTapped: () -> Void

    var body: some View {
        AuthScreenContainer {
            AuthHeader(
                title: "auth.login.title".localized,
                subtitle: "auth.login.subtitle".localized,
                showsBrand: true
            )

            VStack(spacing: 12) {
                CustomTextField(title: "auth.phone".localized, type: .phone, text: $viewModel.phoneNumber)
                CustomTextField(title: "auth.password".localized, type: .password, text: $viewModel.password)
            }

            HStack {
                Spacer()
                Button("auth.forgot_password".localized) {}
                    .font(.footnote.weight(.semibold))
                    .foregroundStyle(AppColor.green)
            }

            validationMessage

            PrimaryButton(title: "auth.login.action".localized) {
                viewModel.submit()
            }

            AuthDivider()

            VStack(spacing: 12) {
                AuthSecondaryButton(title: "auth.continue_google".localized, imageName: "google") {}
                AuthSecondaryButton(title: "auth.continue_apple".localized, imageName: "apple") {}
            }

            AuthPrompt(
                leadingText: "auth.no_account".localized,
                actionTitle: "auth.signup.link".localized,
                action: onSignupTapped
            )
        }
        .navigationBarBackButtonHidden()
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
    LoginView(onSignupTapped: {})
        .environment(LanguageManager.shared)
}
