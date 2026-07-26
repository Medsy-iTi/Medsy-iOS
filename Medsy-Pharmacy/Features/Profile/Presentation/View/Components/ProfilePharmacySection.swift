//
//  ProfilePharmacySection.swift
//  Medsy-Pharmacy
//

import SwiftUI

struct ProfilePharmacySection: View {
    let profile: PharmacyProfile
    let pharmacistCountLabel: String
    let errorMessages: [String]
    let showsPendingInvitations: Bool
    let pendingInvitations: [PharmacyInvitation]
    let isLoadingPendingInvitations: Bool
    let pendingInvitationDeletingId: Int?
    let pendingInvitationsErrorMessage: String?
    let onPharmacyTap: () -> Void
    let onPharmacistsTap: () -> Void
    let onInviteTap: () -> Void
    let onRefreshPendingInvitations: () -> Void
    let onInvitationTap: (PharmacyInvitation) -> Void
    let onDeleteInvitation: (PharmacyInvitation) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: PharmacySpacing.sm) {
            Text("profile.my_pharmacy".localized)
                .font(.headline)
                .foregroundStyle(PharmacyColor.textPrimary)

            if profile.pharmacyId != nil {
                assignedPharmacyContent
            } else {
                NoPharmacyCardView()
            }
        }
    }

    private var assignedPharmacyContent: some View {
        Group {
            ProfileSectionContainer {
                ProfileNavigationRow(
                    icon: "cross.case.fill",
                    title: profile.pharmacyName ?? "pharmacy_card.unknown".localized,
                    subtitle: profile.pharmacyAddress,
                    action: onPharmacyTap
                )

                ProfileRowDivider()

                ProfileNavigationRow(
                    icon: "person.2",
                    title: "pharmacy_team.menu_title".localized,
                    subtitle: pharmacistCountLabel,
                    action: onPharmacistsTap
                )
            }

            if profile.isPharmacyAdmin {
                inviteButton
            }

            if profile.isPharmacyAdmin, showsPendingInvitations {
                PendingInvitationsSectionView(
                    invitations: pendingInvitations,
                    isLoading: isLoadingPendingInvitations,
                    deletingInvitationId: pendingInvitationDeletingId,
                    errorMessage: pendingInvitationsErrorMessage,
                    onRefresh: onRefreshPendingInvitations,
                    onInvitationTap: onInvitationTap,
                    onDeleteInvitation: onDeleteInvitation
                )
            }

            ForEach(Array(errorMessages.enumerated()), id: \.offset) { _, message in
                ProfileInlineErrorText(message: message)
            }
        }
    }

    private var inviteButton: some View {
        Button(action: onInviteTap) {
            HStack(spacing: PharmacySpacing.sm) {
                Image(systemName: "person.badge.plus")

                VStack(alignment: .leading, spacing: 2) {
                    Text("pharmacy_team.invite".localized)
                        .font(.subheadline.weight(.semibold))
                    Text("pharmacy_team.invite_short_description".localized)
                        .font(.caption)
                        .foregroundStyle(PharmacyColor.textSecondary)
                }

                Spacer()
            }
            .foregroundStyle(PharmacyColor.primary)
            .padding(PharmacySpacing.md)
            .frame(maxWidth: .infinity)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .background(PharmacyColor.primarySoft.opacity(0.45))
        .clipShape(RoundedRectangle(cornerRadius: PharmacyRadius.lg, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: PharmacyRadius.lg, style: .continuous)
                .stroke(
                    PharmacyColor.primary.opacity(0.65),
                    style: StrokeStyle(lineWidth: 1, dash: [5, 4])
                )
        }
    }
}

private struct ProfileInlineErrorText: View {
    let message: String

    var body: some View {
        Text(message)
            .font(PharmacyColor.sans(12, .medium))
            .foregroundStyle(PharmacyColor.danger)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, 4)
    }
}
