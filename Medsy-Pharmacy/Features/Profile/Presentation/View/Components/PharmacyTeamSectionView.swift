//
//  PharmacyTeamSectionView.swift
//  Medsy-Pharmacy
//

import SwiftUI

struct PharmacyTeamSectionView: View {
    let members: [PharmacistMember]
    let onEdit: (PharmacistMember) -> Void
    let onRemove: (PharmacistMember) -> Void

    var body: some View {
        ProfileSectionContainer {
            VStack(alignment: .leading, spacing: PharmacySpacing.sm) {
                Text("pharmacy_team.title".localized)
                    .font(PharmacyColor.sans(14, .bold))
                    .foregroundStyle(PharmacyColor.textPrimary)
                    .padding(.horizontal, PharmacySpacing.md)
                    .padding(.top, PharmacySpacing.md)

                if members.isEmpty {
                    Text("pharmacy_team.empty".localized)
                        .font(PharmacyColor.sans(13))
                        .foregroundStyle(PharmacyColor.textSecondary)
                        .padding(.horizontal, PharmacySpacing.md)
                        .padding(.bottom, PharmacySpacing.md)
                } else {
                    ForEach(Array(members.enumerated()), id: \.element.id) { index, member in
                        if index > 0 {
                            ProfileRowDivider()
                        }

                        PharmacyTeamMemberRow(
                            member: member,
                            onEdit: { onEdit(member) },
                            onRemove: { onRemove(member) }
                        )
                    }
                }
            }
        }
    }
}

private struct PharmacyTeamMemberRow: View {
    let member: PharmacistMember
    let onEdit: () -> Void
    let onRemove: () -> Void

    var body: some View {
        HStack(spacing: PharmacySpacing.sm) {
            Image(systemName: "person.circle.fill")
                .font(.system(size: 36))
                .foregroundStyle(PharmacyColor.primary.opacity(0.85))

            VStack(alignment: .leading, spacing: 2) {
                Text(member.fullName)
                    .font(PharmacyColor.sans(14, .semibold))
                    .foregroundStyle(PharmacyColor.textPrimary)
                    .lineLimit(1)

                Text(member.email)
                    .font(PharmacyColor.sans(12))
                    .foregroundStyle(PharmacyColor.textSecondary)
                    .lineLimit(1)
            }

            Spacer(minLength: 0)

            Button(action: onEdit) {
                Image(systemName: "pencil")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundStyle(PharmacyColor.primary)
                    .frame(width: 32, height: 32)
                    .background(PharmacyColor.primary.opacity(0.1))
                    .clipShape(Circle())
            }
            .buttonStyle(.plain)
            .accessibilityLabel("pharmacy_team.edit".localized)

            Button(action: onRemove) {
                Image(systemName: "person.badge.minus")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundStyle(PharmacyColor.danger)
                    .frame(width: 32, height: 32)
                    .background(PharmacyColor.danger.opacity(0.1))
                    .clipShape(Circle())
            }
            .buttonStyle(.plain)
            .accessibilityLabel("pharmacy_team.remove".localized)
        }
        .padding(.horizontal, PharmacySpacing.md)
        .padding(.vertical, PharmacySpacing.sm)
    }
}
