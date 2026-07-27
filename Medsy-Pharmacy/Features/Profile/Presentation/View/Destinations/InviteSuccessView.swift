//
//  InviteSuccessView.swift
//  Medsy-Pharmacy
//

import SwiftUI

struct InviteSuccessView: View {
    let info: InviteSuccessInfo
    let onInviteAnother: () -> Void
    let onBack: () -> Void

    var body: some View {
        ScrollView {
            VStack(spacing: PharmacySpacing.xl) {
                successIcon

                VStack(spacing: PharmacySpacing.xs) {
                    Text("pharmacy_team.invite_success_title".localized)
                        .font(.title2.weight(.bold))
                        .foregroundStyle(PharmacyColor.textPrimary)

                    Text("pharmacy_team.invite_success_subtitle".localized)
                        .font(.subheadline)
                        .foregroundStyle(PharmacyColor.textSecondary)
                        .multilineTextAlignment(.center)
                }

                invitedEmailCard

                VStack(spacing: PharmacySpacing.sm) {
                    Button(action: onInviteAnother) {
                        Text("pharmacy_team.invite_another".localized)
                            .font(.headline)
                            .foregroundStyle(PharmacyColor.primary)
                            .frame(maxWidth: .infinity, minHeight: 50)
                    }
                    .buttonStyle(.plain)
                    .background(PharmacyColor.primarySoft)
                    .clipShape(RoundedRectangle(cornerRadius: PharmacyRadius.md, style: .continuous))

                    Button(action: onBack) {
                        Text("pharmacy_team.back_to_profile".localized)
                            .font(.headline)
                            .foregroundStyle(PharmacyColor.primary)
                            .frame(maxWidth: .infinity, minHeight: 48)
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.horizontal, PharmacySpacing.md)
            .padding(.vertical, PharmacySpacing.xl)
        }
        .background(PharmacyColor.bg.ignoresSafeArea())
        .navigationTitle("pharmacy_team.invite_header".localized)
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden()
    }

    private var successIcon: some View {
        ZStack {
            Circle()
                .fill(PharmacyColor.successSoft)
                .frame(width: 112, height: 112)

            Image(systemName: "checkmark")
                .font(.system(size: 46, weight: .bold))
                .foregroundStyle(PharmacyColor.success)
        }
        .accessibilityHidden(true)
    }

    private var invitedEmailCard: some View {
        VStack(spacing: PharmacySpacing.sm) {
            Label(info.email, systemImage: "envelope")
                .font(.body.weight(.semibold))
                .foregroundStyle(PharmacyColor.textPrimary)

            Label(
                "pharmacy_team.invite_pending".localized,
                systemImage: "clock"
            )
            .font(.caption)
            .foregroundStyle(PharmacyColor.textSecondary)
        }
        .frame(maxWidth: .infinity)
        .padding(PharmacySpacing.lg)
        .background(PharmacyColor.card)
        .clipShape(RoundedRectangle(cornerRadius: PharmacyRadius.lg, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: PharmacyRadius.lg, style: .continuous)
                .stroke(PharmacyColor.border, lineWidth: 1)
        }
    }
}

#Preview {
    NavigationStack {
        InviteSuccessView(
            info: InviteSuccessInfo(
                email: "pharmacist@example.com",
                pharmacyName: "Medsy Pharmacy"
            ),
            onInviteAnother: {},
            onBack: {}
        )
    }
}
