//
//  PharmacistsListView.swift
//  Medsy-Pharmacy
//

import SwiftUI

struct PharmacistsListView: View {
    let members: [PharmacistMember]
    let isAdmin: Bool
    let isInviting: Bool
    let inviteErrorMessage: String?
    let onInvite: () -> Void
    let onDismissError: () -> Void
    let onMemberTap: (PharmacistMember) -> Void

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: PharmacySpacing.md) {
                if members.isEmpty {
                    emptyState
                } else {
                    pharmacySummary

                    Text(String(format: "pharmacy_team.section_header".localized, members.count))
                        .font(.headline)
                        .foregroundStyle(PharmacyColor.textPrimary)

                    LazyVStack(spacing: PharmacySpacing.sm) {
                        ForEach(members) { member in
                            Button {
                                onMemberTap(member)
                            } label: {
                                PharmacistRow(member: member, showsOptions: isAdmin && !member.isAdmin)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                }

                if isAdmin {
                    inviteButton
                }

                if let inviteErrorMessage {
                    errorCard(inviteErrorMessage)
                }
            }
            .padding(.horizontal, PharmacySpacing.md)
            .padding(.vertical, PharmacySpacing.md)
        }
        .background(PharmacyColor.bg.ignoresSafeArea())
        .navigationTitle("pharmacy_team.menu_title".localized)
        .navigationBarTitleDisplayMode(.inline)
    }

    private var pharmacySummary: some View {
        HStack(spacing: PharmacySpacing.md) {
            Image(systemName: "cross.case.fill")
                .font(.title2.weight(.semibold))
                .foregroundStyle(.white)
                .frame(width: 56, height: 56)
                .background(PharmacyColor.primaryDark, in: Circle())

            VStack(alignment: .leading, spacing: PharmacySpacing.xxs) {
                Text("profile.pharmacy_profile".localized)
                    .font(.headline)
                    .foregroundStyle(PharmacyColor.textPrimary)
                Text("profile.pharmacists_count".localized(members.count))
                    .font(.subheadline)
                    .foregroundStyle(PharmacyColor.textSecondary)
            }

            Spacer()
        }
        .padding(PharmacySpacing.md)
        .background(PharmacyColor.card)
        .clipShape(RoundedRectangle(cornerRadius: PharmacyRadius.lg, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: PharmacyRadius.lg, style: .continuous)
                .stroke(PharmacyColor.border, lineWidth: 1)
        }
    }

    private var emptyState: some View {
        ContentUnavailableView(
            "pharmacy_team.empty".localized,
            systemImage: "person.2"
        )
        .frame(maxWidth: .infinity, minHeight: 280)
    }

    private var inviteButton: some View {
        Button(action: onInvite) {
            HStack(spacing: PharmacySpacing.sm) {
                if isInviting {
                    ProgressView().tint(PharmacyColor.primary)
                } else {
                    Image(systemName: "person.badge.plus")
                }

                Text("pharmacy_team.invite".localized)
                    .font(.headline)
            }
            .foregroundStyle(PharmacyColor.primary)
            .frame(maxWidth: .infinity, minHeight: 52)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .disabled(isInviting)
        .background(PharmacyColor.primarySoft.opacity(0.4))
        .clipShape(RoundedRectangle(cornerRadius: PharmacyRadius.md, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: PharmacyRadius.md, style: .continuous)
                .stroke(
                    PharmacyColor.primary.opacity(0.65),
                    style: StrokeStyle(lineWidth: 1, dash: [5, 4])
                )
        }
    }

    private func errorCard(_ message: String) -> some View {
        HStack(spacing: PharmacySpacing.sm) {
            Image(systemName: "exclamationmark.triangle.fill")
                .foregroundStyle(PharmacyColor.danger)
            Text(message)
                .font(.caption)
                .foregroundStyle(PharmacyColor.danger)
            Spacer()
            Button(action: onDismissError) {
                Image(systemName: "xmark")
            }
            .buttonStyle(.plain)
            .foregroundStyle(PharmacyColor.danger)
        }
        .padding(PharmacySpacing.md)
        .background(
            PharmacyColor.danger.opacity(0.1),
            in: RoundedRectangle(cornerRadius: PharmacyRadius.md, style: .continuous)
        )
    }
}

private struct PharmacistRow: View {
    let member: PharmacistMember
    let showsOptions: Bool

    var body: some View {
        HStack(spacing: PharmacySpacing.sm) {
            PharmacistAvatarView(pharmacist: member.toPharmacist(), diameter: 52)

            VStack(alignment: .leading, spacing: 2) {
                HStack(spacing: PharmacySpacing.xxs) {
                    Text(member.fullName)
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(PharmacyColor.textPrimary)
                        .lineLimit(1)

                    if member.isAdmin {
                        PillBadge(text: "pharmacy_team.admin_badge".localized)
                    }
                }

                Text("profile.role_pharmacist".localized)
                    .font(.caption.weight(.medium))
                    .foregroundStyle(PharmacyColor.primary)

                Text(member.email)
                    .font(.caption2)
                    .foregroundStyle(PharmacyColor.textSecondary)
                    .lineLimit(1)
            }

            Spacer()

            Image(systemName: showsOptions ? "ellipsis" : "chevron.forward")
                .font(.footnote.weight(.semibold))
                .foregroundStyle(PharmacyColor.textSecondary)
                .frame(width: 28, height: 28)
        }
        .padding(PharmacySpacing.md)
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
        PharmacistsListView(
            members: [
                PharmacistMember(
                    id: 1,
                    firstName: "Ahmed",
                    lastName: "Mohamed",
                    email: "ahmed@example.com",
                    phoneNumber: "010 1234 5678",
                    isAdmin: true
                ),
                PharmacistMember(
                    id: 2,
                    firstName: "Mona",
                    lastName: "Mahmoud",
                    email: "mona@example.com",
                    phoneNumber: "011 2345 6789",
                    isAdmin: false
                )
            ],
            isAdmin: true,
            isInviting: false,
            inviteErrorMessage: nil,
            onInvite: {},
            onDismissError: {},
            onMemberTap: { _ in }
        )
    }
}
