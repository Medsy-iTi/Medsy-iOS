//
//  PendingInvitationsSectionView.swift
//  Medsy-Pharmacy
//

import SwiftUI

struct PendingInvitationsSectionView: View {
    let invitations: [PharmacyInvitation]
    let isLoading: Bool
    let deletingInvitationId: Int?
    let errorMessage: String?
    let onRefresh: () -> Void
    let onInvitationTap: (PharmacyInvitation) -> Void
    let onDeleteInvitation: (PharmacyInvitation) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: PharmacySpacing.sm) {
            header

            if isLoading {
                loadingRows
            } else if let errorMessage {
                errorCard(errorMessage)
            } else if invitations.isEmpty {
                emptyCard
            } else {
                invitationRows
            }
        }
        .padding(PharmacySpacing.md)
        .background(PharmacyColor.card)
        .clipShape(RoundedRectangle(cornerRadius: PharmacyRadius.lg, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: PharmacyRadius.lg, style: .continuous)
                .stroke(PharmacyColor.border, lineWidth: 1)
        }
    }

    private var header: some View {
        HStack(spacing: PharmacySpacing.sm) {
            ZStack {
                Circle()
                    .fill(PharmacyColor.warningSoft)
                    .frame(width: 36, height: 36)
                Image(systemName: "envelope.badge")
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundStyle(PharmacyColor.warning)
            }

            VStack(alignment: .leading, spacing: 2) {
                Text("pharmacy_pending_invitations.title".localized)
                    .font(PharmacyColor.sans(15, .bold))
                    .foregroundStyle(PharmacyColor.textPrimary)
                Text("pharmacy_pending_invitations.subtitle".localized)
                    .font(PharmacyColor.sans(12))
                    .foregroundStyle(PharmacyColor.textSecondary)
            }

            Spacer()

            Button(action: onRefresh) {
                Image(systemName: "arrow.clockwise")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(PharmacyColor.primary)
                    .frame(width: 34, height: 34)
                    .background(PharmacyColor.primary.opacity(0.1))
                    .clipShape(Circle())
            }
            .buttonStyle(.plain)
            .accessibilityLabel("refresh".localized)
        }
    }

    private var loadingRows: some View {
        VStack(spacing: PharmacySpacing.sm) {
            ForEach(0..<2, id: \.self) { _ in
                RoundedRectangle(cornerRadius: PharmacyRadius.md, style: .continuous)
                    .fill(PharmacyColor.mutedSurface)
                    .frame(height: 72)
                    .redacted(reason: .placeholder)
            }
        }
    }

    private var invitationRows: some View {
        VStack(spacing: PharmacySpacing.sm) {
            ForEach(invitations, id: \.id) { invitation in
                PendingInvitationRow(
                    invitation: invitation,
                    isDeleting: deletingInvitationId == invitation.id,
                    onTap: { onInvitationTap(invitation) },
                    onDelete: { onDeleteInvitation(invitation) }
                )
            }
        }
    }

    private var emptyCard: some View {
        HStack(spacing: PharmacySpacing.sm) {
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 18, weight: .semibold))
                .foregroundStyle(PharmacyColor.success)
            Text("pharmacy_pending_invitations.empty".localized)
                .font(PharmacyColor.sans(13, .medium))
                .foregroundStyle(PharmacyColor.textSecondary)
            Spacer()
        }
        .padding(PharmacySpacing.md)
        .background(PharmacyColor.successSoft.opacity(0.7))
        .clipShape(RoundedRectangle(cornerRadius: PharmacyRadius.md, style: .continuous))
    }

    private func errorCard(_ message: String) -> some View {
        HStack(spacing: PharmacySpacing.sm) {
            Image(systemName: "exclamationmark.triangle.fill")
                .foregroundStyle(PharmacyColor.danger)
            Text(message)
                .font(PharmacyColor.sans(13, .medium))
                .foregroundStyle(PharmacyColor.danger)
            Spacer()
        }
        .padding(PharmacySpacing.md)
        .background(PharmacyColor.danger.opacity(0.1))
        .clipShape(RoundedRectangle(cornerRadius: PharmacyRadius.md, style: .continuous))
    }
}

private struct PendingInvitationRow: View {
    let invitation: PharmacyInvitation
    let isDeleting: Bool
    let onTap: () -> Void
    let onDelete: () -> Void

    var body: some View {
        HStack(spacing: PharmacySpacing.sm) {
            Button(action: onTap) {
                HStack(spacing: PharmacySpacing.sm) {
                    invitationIcon
                    invitationText
                    Spacer(minLength: PharmacySpacing.xs)
                    Image(systemName: "chevron.forward")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundStyle(PharmacyColor.textSecondary.opacity(0.7))
                }
                .contentShape(Rectangle())
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            .buttonStyle(.plain)

            Button(role: .destructive, action: onDelete) {
                if isDeleting {
                    ProgressView()
                        .tint(PharmacyColor.danger)
                } else {
                    Image(systemName: "trash")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundStyle(PharmacyColor.danger)
                }
            }
            .buttonStyle(.plain)
            .frame(width: 36, height: 36)
        }
        .padding(PharmacySpacing.sm)
        .background(PharmacyColor.mutedSurface)
        .clipShape(RoundedRectangle(cornerRadius: PharmacyRadius.md, style: .continuous))
    }

    private var invitationIcon: some View {
        ZStack {
            Circle()
                .fill(PharmacyColor.primary.opacity(0.12))
                .frame(width: 42, height: 42)
            Image(systemName: "person.crop.circle.badge.clock")
                .font(.system(size: 17, weight: .semibold))
                .foregroundStyle(PharmacyColor.primary)
        }
    }

    private var invitationText: some View {
        VStack(alignment: .leading, spacing: 3) {
            Text(invitation.pharmacistFullName)
                .font(PharmacyColor.sans(14, .semibold))
                .foregroundStyle(PharmacyColor.textPrimary)
                .lineLimit(1)

            HStack(spacing: PharmacySpacing.xs) {
                Text(invitation.status.capitalized)
                    .font(PharmacyColor.sans(11, .bold))
                    .foregroundStyle(PharmacyColor.warning)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 3)
                    .background(PharmacyColor.warningSoft)
                    .clipShape(Capsule())

                if let createdAt = invitation.createdAt {
                    Text(Self.relativeFormatter.localizedString(for: createdAt, relativeTo: Date()))
                        .font(PharmacyColor.sans(11))
                        .foregroundStyle(PharmacyColor.textSecondary)
                }
            }
        }
    }

    private static let relativeFormatter: RelativeDateTimeFormatter = {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .short
        return formatter
    }()
}

struct PendingInvitationDetailView: View {
    let invitation: PharmacyInvitation
    let isDeleting: Bool
    let errorMessage: String?
    let onDelete: () -> Void
    let onDismissError: () -> Void

    var body: some View {
        ScrollView {
            VStack(spacing: PharmacySpacing.md) {
                summaryCard
                detailCard

                Button(role: .destructive, action: onDelete) {
                    HStack(spacing: PharmacySpacing.sm) {
                        if isDeleting {
                            ProgressView().tint(PharmacyColor.danger)
                        } else {
                            Image(systemName: "trash")
                            Text("pharmacy_pending_invitations.delete".localized)
                        }
                    }
                    .font(PharmacyColor.sans(15, .semibold))
                    .foregroundStyle(PharmacyColor.danger)
                    .frame(maxWidth: .infinity)
                    .frame(height: 54)
                    .background(PharmacyColor.danger.opacity(0.1))
                    .clipShape(RoundedRectangle(cornerRadius: PharmacyRadius.lg, style: .continuous))
                }
                .buttonStyle(.plain)
                .disabled(isDeleting)

                if let errorMessage {
                    HStack(spacing: PharmacySpacing.sm) {
                        Image(systemName: "exclamationmark.triangle.fill")
                            .foregroundStyle(PharmacyColor.danger)
                        Text(errorMessage)
                            .font(PharmacyColor.sans(13, .medium))
                            .foregroundStyle(PharmacyColor.danger)
                        Spacer()
                        Button(action: onDismissError) {
                            Image(systemName: "xmark")
                                .foregroundStyle(PharmacyColor.danger)
                        }
                    }
                    .padding(PharmacySpacing.md)
                    .background(PharmacyColor.danger.opacity(0.1))
                    .clipShape(RoundedRectangle(cornerRadius: PharmacyRadius.md, style: .continuous))
                }
            }
            .padding(PharmacySpacing.md)
        }
        .background(PharmacyColor.bg.ignoresSafeArea())
        .navigationTitle("pharmacy_pending_invitations.details_title".localized)
        .navigationBarTitleDisplayMode(.inline)
    }

    private var summaryCard: some View {
        VStack(spacing: PharmacySpacing.sm) {
            ZStack {
                Circle()
                    .fill(PharmacyColor.primary.opacity(0.12))
                    .frame(width: 74, height: 74)
                Image(systemName: "person.crop.circle.badge.clock")
                    .font(.system(size: 30, weight: .semibold))
                    .foregroundStyle(PharmacyColor.primary)
            }

            Text(invitation.pharmacistFullName)
                .font(PharmacyColor.sans(20, .bold))
                .foregroundStyle(PharmacyColor.textPrimary)

            Text(invitation.status.capitalized)
                .font(PharmacyColor.sans(12, .bold))
                .foregroundStyle(PharmacyColor.warning)
                .padding(.horizontal, PharmacySpacing.sm)
                .padding(.vertical, PharmacySpacing.xs)
                .background(PharmacyColor.warningSoft)
                .clipShape(Capsule())
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

    private var detailCard: some View {
        VStack(spacing: 0) {
            detailRow(title: "pharmacy_pending_invitations.pharmacy".localized, value: invitation.pharmacyName)
            if let createdAt = invitation.createdAt {
                ProfileRowDivider()
                detailRow(
                    title: "pharmacy_pending_invitations.created_at".localized,
                    value: Self.dateFormatter.string(from: createdAt)
                )
            }
        }
        .padding(.horizontal, PharmacySpacing.md)
        .background(PharmacyColor.card)
        .clipShape(RoundedRectangle(cornerRadius: PharmacyRadius.lg, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: PharmacyRadius.lg, style: .continuous)
                .stroke(PharmacyColor.border, lineWidth: 1)
        }
    }

    private func detailRow(title: String, value: String) -> some View {
        HStack(alignment: .top, spacing: PharmacySpacing.md) {
            Text(title)
                .font(PharmacyColor.sans(13, .medium))
                .foregroundStyle(PharmacyColor.textSecondary)
            Spacer()
            Text(value)
                .font(PharmacyColor.sans(14, .semibold))
                .foregroundStyle(PharmacyColor.textPrimary)
                .multilineTextAlignment(.trailing)
        }
        .padding(.vertical, PharmacySpacing.md)
    }

    private static let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter
    }()
}
