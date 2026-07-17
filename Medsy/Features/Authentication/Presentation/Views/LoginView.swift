//
//  LoginView.swift
//  Medsy
//
//  Created by Ehab Salah on 16/07/2026.
//

import SwiftUI

struct LoginView: View {
    @State private var viewModel = LoginViewModel()
    let onSignupTapped: () -> Void
    let onAuthenticated: () -> Void

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

            AuthValidationMessage(message: viewModel.validationMessage)

            PrimaryButton(title: "auth.login.action".localized) {
                if viewModel.submit() {
                    onAuthenticated()
                }
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

}

#Preview {
    LoginView(onSignupTapped: {}, onAuthenticated: {})
        .environment(LanguageManager.shared)
}
