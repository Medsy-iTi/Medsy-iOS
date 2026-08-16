//
//  VerificationView.swift
//  Medsy
//
//  Created by Ehab Salah on 17/07/2026.

import SwiftUI

struct VerificationView: View {
    let email: String
    let onAuthenticated: () -> Void
    @State private var viewModel: VerificationViewModel

    init(
        email: String,
        viewModel: VerificationViewModel,
        onAuthenticated: @escaping () -> Void
    ) {
        self.email = email
        _viewModel = State(initialValue: viewModel)
        self.onAuthenticated = onAuthenticated
    }

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
                isLoading: viewModel.isLoading,
                isDisabled: viewModel.code.count != 6 || viewModel.isLoading
            ) {
                Task {
                    if await viewModel.submit(email: email) {
                        onAuthenticated()
                    }
                }
            }


        }
        .navigationTitle("auth.verification.title".localized)
        .navigationBarTitleDisplayMode(.inline)
        .showCustomAlert(
            title: "common.error".localized,
            alertMessage: Binding(
                get: { viewModel.alertMessage },
                set: { value in
                    if value == nil {
                        viewModel.dismissError()
                    }
                }
            )
        )
    }
}

#Preview {
    NavigationStack {
        VerificationView(
            email: "ehab@example.com",
            viewModel: VerificationViewModel(verificationUseCase: PreviewVerificationUseCase()),
            onAuthenticated: {}
        )
    }
    .environment(LanguageManager.shared)
}

private struct PreviewVerificationUseCase: VerificationUseCaseProtocol {
    func execute(input: VerificationInput) async throws -> AuthenticatedSession {
        AuthenticatedSession(
            accessToken: "",
            refreshToken: "",
            user: AuthenticatedUser(
                id: 0,
                email: input.email,
                firstName: "",
                lastName: "",
                role: "CUSTOMER",
                homeAddress: "",
                dateOfBirth: "",
                homeLatitude: nil,
                homeLongitude: nil
            )
        )
    }
}
