//
//  PharmacyAiChatSuggestionCard.swift
//  Medsy-Pharmacy

import SwiftUI

struct PharmacyAiChatSuggestionCard: View {
    var onSelect: (String) -> Void
    
    private let suggestions = [
        ("chart.bar.fill", "pharmacy.chatbot.suggestion.performance".localized),
        ("pills.fill", "pharmacy.chatbot.suggestion.drug_info".localized),
        ("exclamationmark.triangle.fill", "pharmacy.chatbot.suggestion.interactions".localized)
    ]
    
    var body: some View {
        VStack(alignment: .leading, spacing: PharmacySpacing.sm) {
            ForEach(suggestions, id: \.1) { icon, text in
                Button(action: { onSelect(text) }) {
                    HStack(spacing: 12) {
                        Image(systemName: icon)
                            .font(.system(size: 14))
                            .foregroundColor(PharmacyColor.primary)
                            .frame(width: 20)
                        
                        Text(text)
                            .font(PharmacyColor.sans(14, .medium))
                            .foregroundColor(PharmacyColor.textPrimary)
                            .multilineTextAlignment(.leading)
                        
                        Spacer()
                        
                        Image(systemName: "arrow.up.right")
                            .font(.system(size: 12, weight: .bold))
                            .foregroundColor(PharmacyColor.primary.opacity(0.5))
                    }
                    .padding(14)
                    .background(PharmacyColor.surface)
                    .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                    .overlay(
                        RoundedRectangle(cornerRadius: 12, style: .continuous)
                            .stroke(PharmacyColor.border.opacity(0.6), lineWidth: 1)
                    )
                }
                .buttonStyle(.plain)
            }
        }
        .padding(PharmacySpacing.md)
    }
}
