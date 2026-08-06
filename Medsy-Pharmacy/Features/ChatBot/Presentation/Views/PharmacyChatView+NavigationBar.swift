//
//  PharmacyChatView+NavigationBar.swift
//  Medsy-Pharmacy

import SwiftUI

extension PharmacyChatView {
    var navigationBar: some View {
        HStack {
            Image("PharmacyChatBotAvatar") // Requires asset, fallback below
                .resizable()
                .scaledToFit()
                .frame(width: 36, height: 36)
                .clipShape(Circle())
                .overlay(Circle().stroke(PharmacyColor.border, lineWidth: 1))
            
            VStack(alignment: .leading, spacing: 2) {
                Text("pharmacy.chatbot.title".localized)
                    .font(PharmacyColor.sans(16, .bold))
                    .foregroundColor(PharmacyColor.textPrimary)
                HStack(spacing: 4) {
                    Circle()
                        .fill(PharmacyColor.success)
                        .frame(width: 8, height: 8)
                    Text("pharmacy.chatbot.status.online".localized)
                        .font(PharmacyColor.sans(12))
                        .foregroundColor(PharmacyColor.textSecondary)
                }
            }
            Spacer()
            
            Menu {
                Button(role: .destructive, action: { viewModel.startNewChat() }) {
                    Label("pharmacy.chatbot.menu.new_chat".localized, systemImage: "trash")
                }
            } label: {
                Image(systemName: "ellipsis")
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundColor(PharmacyColor.textSecondary)
                    .frame(width: 44, height: 44)
            }
        }
    }
}
