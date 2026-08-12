//
//  PharmacyAiChatReminderBubble.swift
//  Medsy-Pharmacy

import SwiftUI

struct PharmacyAiChatReminderBubble: View {
    var title: String
    var time: String

    var body: some View {
        HStack(spacing: 12) {
            ZStack {
                Circle()
                    .fill(PharmacyColor.primarySoft)
                    .frame(width: 36, height: 36)
                Image(systemName: "alarm.fill")
                    .font(.system(size: 16))
                    .foregroundColor(PharmacyColor.primary)
            }
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(PharmacyColor.sans(14, .semibold))
                    .foregroundColor(PharmacyColor.textPrimary)
                
                Text(time)
                    .font(PharmacyColor.sans(12))
                    .foregroundColor(PharmacyColor.textSecondary)
            }
            Spacer()
        }
        .padding(12)
        .background(PharmacyColor.surface)
        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .stroke(PharmacyColor.border.opacity(0.5), lineWidth: 1)
        )
    }
}
