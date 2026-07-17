//
//  VerificationView.swift
//  Medsy
//
//  Created by Ehab Salah on 17/07/2026.

import SwiftUI

struct VerificationView: View {
    let email: String
    let onAuthenticated: () -> Void

    @State private var viewModel = VerificationViewModel()

    var body: some View {
        AuthScreenContainer {
            AuthHeader(
                title: "auth.verification.title".localized,
                subtitle: "auth.verification.subtitle".localized
            )

            VStack(spacing: 18) {
                Text("auth.verification.sent_to".localized(email))
                    .font(.subheadline)
                    .foregroundStyle(AppColor.textSec)
                    .multilineTextAlignment(.center)

                OTPInputView(code: Binding(
                    get: { viewModel.code },
                    set: viewModel.updateCode
                ))

                AuthValidationMessage(message: viewModel.validationMessage)
            }

            PrimaryButton(
                title: "auth.verification.action".localized,
                isDisabled: viewModel.code.count != 6
            ) {
                if viewModel.submit() {
                    onAuthenticated()
                }
            }

            Button("auth.verification.resend".localized) {
                viewModel.clearValidationMessage()
            }
            .font(.subheadline.weight(.semibold))
            .foregroundStyle(AppColor.green)
        }
        .navigationTitle("auth.verification.title".localized)
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    NavigationStack {
        VerificationView(email: "ehab@example.com", onAuthenticated: {})
    }
    .environment(LanguageManager.shared)
}
