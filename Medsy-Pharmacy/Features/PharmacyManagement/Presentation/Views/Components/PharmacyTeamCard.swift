//
//  PharmacyTeamCard.swift
//  Medsy-Pharmacy
//
//  Created by Ahmed Elkady on 19/07/2026.
//

import SwiftUI

struct PharmacyTeamCard: View {
    let members: [PharmacyTeamMemberDisplayModel]

    var body: some View {
        VStack(alignment: .leading, spacing: PharmacySpacing.md) {
            HStack {
                Text("pharmacy.management.team.title".localized)
                    .font(PharmacyColor.sans(16, .bold))
                    .foregroundStyle(PharmacyColor.textPrimary)

                Spacer()

                Text(String(members.count))
                    .font(PharmacyColor.sans(12, .bold))
                    .foregroundStyle(PharmacyColor.primary)
                    .frame(minWidth: 28, minHeight: 28)
                    .background(PharmacyColor.primarySoft, in: Capsule())
            }

            ForEach(Array(members.enumerated()), id: \.element.id) { index, member in
                if index > 0 {
                    Divider()
                        .overlay(PharmacyColor.border)
                }

                HStack(spacing: PharmacySpacing.sm) {
                    Image(systemName: "person.fill")
                        .foregroundStyle(PharmacyColor.primary)
                        .frame(width: 38, height: 38)
                        .background(PharmacyColor.primarySoft, in: Circle())

                    VStack(alignment: .leading, spacing: PharmacySpacing.xxs) {
                        HStack(spacing: PharmacySpacing.xs) {
                            Text(member.fullName)
                                .font(PharmacyColor.sans(14, .semibold))
                                .foregroundStyle(PharmacyColor.textPrimary)

                            if member.isAdmin {
                                Text("pharmacy.management.role.admin".localized)
                                    .font(PharmacyColor.sans(10, .bold))
                                    .foregroundStyle(PharmacyColor.primary)
                            }
                        }

                        Text(member.email)
                            .font(PharmacyColor.sans(12))
                            .foregroundStyle(PharmacyColor.textSecondary)
                            .lineLimit(1)
                    }

                    Spacer()
                }
            }
        }
        .padding(PharmacySpacing.md)
        .background(PharmacyColor.card, in: RoundedRectangle(cornerRadius: PharmacyRadius.lg, style: .continuous))
        .overlay(RoundedRectangle(cornerRadius: PharmacyRadius.lg, style: .continuous).stroke(PharmacyColor.border))
    }
}
