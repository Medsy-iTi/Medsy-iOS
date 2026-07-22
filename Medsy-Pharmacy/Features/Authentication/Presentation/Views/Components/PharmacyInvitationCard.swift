import SwiftUI

struct PharmacyInvitationCard: View {
    let invitation: PendingPharmacyInvitation
    let isActing: Bool
    let actionsDisabled: Bool
    let onAccept: () -> Void
    let onDecline: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: PharmacySpacing.md) {
            HStack(alignment: .top, spacing: PharmacySpacing.sm) {
                Image(systemName: "cross.case.fill")
                    .font(.system(size: 22, weight: .semibold))
                    .foregroundStyle(PharmacyColor.primary)
                    .frame(width: 48, height: 48)
                    .background(PharmacyColor.primarySoft, in: RoundedRectangle(cornerRadius: PharmacyRadius.md))

                VStack(alignment: .leading, spacing: PharmacySpacing.xxs) {
                    Text(invitation.pharmacyName)
                        .font(PharmacyColor.sans(17, .bold))
                        .foregroundStyle(PharmacyColor.textPrimary)
                        .lineLimit(2)

                    Text("pharmacy.invitations.invited_to_join".localized)
                        .font(PharmacyColor.sans(13))
                        .foregroundStyle(PharmacyColor.textSecondary)

                    if let createdAt = invitation.createdAt {
                        Label(
                            "pharmacy.invitations.received_on".localized(
                                createdAt.formatted(date: .abbreviated, time: .omitted)
                            ),
                            systemImage: "calendar"
                        )
                        .font(PharmacyColor.sans(12, .medium))
                        .foregroundStyle(PharmacyColor.textSecondary)
                    }
                }

                Spacer(minLength: 0)

                Text("pharmacy.invitations.pending".localized)
                    .font(PharmacyColor.sans(11, .semibold))
                    .foregroundStyle(PharmacyColor.warning)
                    .padding(.horizontal, PharmacySpacing.xs)
                    .padding(.vertical, PharmacySpacing.xxs)
                    .background(PharmacyColor.warningSoft, in: Capsule())
            }

            HStack(spacing: PharmacySpacing.sm) {
                Button(action: onDecline) {
                    Text("pharmacy.invitations.decline".localized)
                        .font(PharmacyColor.sans(14, .semibold))
                        .foregroundStyle(PharmacyColor.danger)
                        .frame(maxWidth: .infinity)
                        .frame(height: 46)
                        .background(PharmacyColor.card, in: RoundedRectangle(cornerRadius: PharmacyRadius.md))
                        .overlay(
                            RoundedRectangle(cornerRadius: PharmacyRadius.md)
                                .stroke(PharmacyColor.danger.opacity(0.45), lineWidth: 1)
                        )
                }
                .buttonStyle(.plain)
                .disabled(actionsDisabled)

                PharmacyPrimaryButton(
                    title: "pharmacy.invitations.accept".localized,
                    isLoading: isActing,
                    isDisabled: actionsDisabled && !isActing,
                    height: 46,
                    action: onAccept
                )
            }
        }
        .padding(PharmacySpacing.md)
        .background(PharmacyColor.card, in: RoundedRectangle(cornerRadius: PharmacyRadius.lg))
        .overlay(
            RoundedRectangle(cornerRadius: PharmacyRadius.lg)
                .stroke(PharmacyColor.border, lineWidth: 1)
        )
        .accessibilityElement(children: .contain)
    }
}
