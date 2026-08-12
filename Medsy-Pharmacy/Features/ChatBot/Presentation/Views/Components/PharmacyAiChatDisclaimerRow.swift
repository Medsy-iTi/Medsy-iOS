//
//  PharmacyAiChatDisclaimerRow.swift
//  Medsy-Pharmacy

import SwiftUI

struct PharmacyAiChatDisclaimerRow: View {
    var text: String

    var body: some View {
        HStack(alignment: .top, spacing: PharmacySpacing.xs) {
            Image(systemName: "info.circle.fill")
                .font(.system(size: 12))
                .foregroundColor(PharmacyColor.warning)
            Text(text)
                .font(PharmacyColor.sans(12))
                .foregroundColor(PharmacyColor.textSecondary)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(.horizontal, PharmacySpacing.sm)
        .padding(.vertical, PharmacySpacing.xs)
        .background(PharmacyColor.warningSoft)
        .clipShape(RoundedRectangle(cornerRadius: PharmacyRadius.sm, style: .continuous))
    }
}
