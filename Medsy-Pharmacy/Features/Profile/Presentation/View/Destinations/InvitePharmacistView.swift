//
//  InvitePharmacistView.swift
//  Medsy-Pharmacy
//

import SwiftUI

struct InvitePharmacistView: View {
    let pharmacyName: String
    let isInviting: Bool
    let errorMessage: String?
    let onInvite: (String) async -> Bool

    @State private var email = ""
    @State private var validationError: String?
    @FocusState private var isEmailFocused: Bool

    var body: some View {
        ScrollView {
            VStack(spacing: PharmacySpacing.xl) {
                invitationIllustration

                VStack(spacing: PharmacySpacing.xs) {
                    Text("pharmacy_team.invite_title".localized)
                        .font(.title3.weight(.bold))
                        .foregroundStyle(PharmacyColor.textPrimary)

                    Text(String(format: "pharmacy_team.invite_subtitle".localized, pharmacyName))
                        .font(.subheadline)
                        .foregroundStyle(PharmacyColor.textSecondary)
                        .multilineTextAlignment(.center)
                }

                emailField

                if let message = validationError ?? errorMessage {
                    Label(message, systemImage: "exclamationmark.circle.fill")
                        .font(.caption)
                        .foregroundStyle(PharmacyColor.danger)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
            }
            .padding(.horizontal, PharmacySpacing.md)
            .padding(.vertical, PharmacySpacing.xl)
        }
        .background(PharmacyColor.bg.ignoresSafeArea())
        .navigationTitle("pharmacy_team.invite_header".localized)
        .navigationBarTitleDisplayMode(.inline)
        .safeAreaInset(edge: .bottom) {
            inviteButton
                .padding(.horizontal, PharmacySpacing.md)
                .padding(.vertical, PharmacySpacing.sm)
                .background(PharmacyColor.surface)
                .overlay(alignment: .top) {
                    Rectangle().fill(PharmacyColor.border).frame(height: 1)
                }
        }
    }

    private var invitationIllustration: some View {
        ZStack {
            RoundedRectangle(cornerRadius: PharmacyRadius.xl, style: .continuous)
                .fill(PharmacyColor.primarySoft)
                .frame(width: 108, height: 92)

            Image(systemName: "envelope.open.fill")
                .font(.system(size: 44, weight: .medium))
                .foregroundStyle(PharmacyColor.primary.opacity(0.35))

            Image(systemName: "person.badge.plus")
                .font(.system(size: 34, weight: .semibold))
                .foregroundStyle(PharmacyColor.primary)
                .padding(12)
                .background(PharmacyColor.card, in: Circle())
                .offset(y: -18)
        }
        .accessibilityHidden(true)
    }

    private var emailField: some View {
        VStack(alignment: .leading, spacing: PharmacySpacing.xs) {
            Text("pharmacy_team.invite_email".localized)
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(PharmacyColor.textPrimary)

            HStack(spacing: PharmacySpacing.sm) {
                Image(systemName: "envelope")
                    .foregroundStyle(PharmacyColor.textSecondary)

                TextField(
                    "pharmacy_team.invite_email_placeholder".localized,
                    text: $email
                )
                .font(.body)
                .keyboardType(.emailAddress)
                .textInputAutocapitalization(.never)
                .autocorrectionDisabled()
                .focused($isEmailFocused)
                .onChange(of: email) {
                    validationError = nil
                }
            }
            .padding(.horizontal, PharmacySpacing.md)
            .frame(minHeight: 56)
            .pharmacyInputSurface(isFocused: isEmailFocused)
        }
    }

    private var inviteButton: some View {
        PharmacyPrimaryButton(
            title: "pharmacy_team.invite_button".localized,
            systemImage: "paperplane.fill",
            isLoading: isInviting,
            isDisabled: isInviting,
            action: invite
        )
    }

    private func invite() {
        let trimmedEmail = email.trimmingCharacters(in: .whitespacesAndNewlines)
        guard trimmedEmail.contains("@"), trimmedEmail.contains(".") else {
            validationError = "pharmacy_team.validation_email".localized
            return
        }

        validationError = nil
        Task {
            _ = await onInvite(trimmedEmail)
        }
    }
}

#Preview {
    NavigationStack {
        InvitePharmacistView(
            pharmacyName: "Test Pharmacy",
            isInviting: false,
            errorMessage: nil,
            onInvite: { _ in true }
        )
    }
}
