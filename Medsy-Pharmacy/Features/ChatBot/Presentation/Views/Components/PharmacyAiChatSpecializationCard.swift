//
//  PharmacyAiChatSpecializationCard.swift
//  Medsy-Pharmacy

import SwiftUI

struct PharmacyAiChatSpecializationCard: View {
    var specializations: [String]
    var accentColor: Color = PharmacyColor.primary

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 6) {
                Image(systemName: "stethoscope")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(accentColor)
                Text("pharmacy.chatbot.specialization.header".localized)
                    .font(PharmacyColor.sans(13, .semibold))
                    .foregroundColor(PharmacyColor.textSecondary)
            }

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    ForEach(specializations, id: \.self) { specialization in
                        Text(specialization)
                            .font(PharmacyColor.sans(13, .medium))
                            .foregroundColor(accentColor)
                            .padding(.horizontal, 14)
                            .padding(.vertical, 7)
                            .background(accentColor.opacity(0.08))
                            .overlay(
                                Capsule().stroke(accentColor.opacity(0.35), lineWidth: 1)
                            )
                            .clipShape(Capsule())
                    }
                }
                .padding(.horizontal, 2)
            }
        }
        .padding(14)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(PharmacyColor.surface)
        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
        .shadow(color: .black.opacity(0.05), radius: 5, y: 2)
    }
}
