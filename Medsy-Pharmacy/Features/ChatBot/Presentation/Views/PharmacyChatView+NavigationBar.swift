//
//  PharmacyChatView+NavigationBar.swift
//  Medsy-Pharmacy

import SwiftUI

extension PharmacyChatView {
    var navigationBar: some View {
        HStack {
            // AI Avatar
            ZStack {
                RoundedRectangle(cornerRadius: PharmacyRadius.sm, style: .continuous)
                    .fill(PharmacyColor.primary)
                Image(systemName: "sparkles")
                    .foregroundColor(.white)
                    .font(.system(size: 13, weight: .bold))
            }
            .frame(width: 34, height: 34)

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

            // New chat
            Button(action: { showingNewChatAlert = true }) {
                Image(systemName: "square.and.pencil")
                    .font(.system(size: 17))
                    .foregroundColor(PharmacyColor.textSecondary)
                    .frame(width: 36, height: 36)
                    .background(PharmacyColor.mutedSurface)
                    .clipShape(Circle())
            }
            .buttonStyle(.plain)

            // Dark mode toggle
            Button {
                withAnimation(.spring(response: 0.35, dampingFraction: 0.7)) {
                    appSettings.toggleLightAndDark()
                }
            } label: {
                Image(systemName: appSettings.isDarkMode ? "sun.max.fill" : "moon.fill")
                    .font(.system(size: 15))
                    .foregroundColor(PharmacyColor.textSecondary)
                    .frame(width: 36, height: 36)
                    .background(PharmacyColor.mutedSurface)
                    .clipShape(Circle())
            }
            .buttonStyle(.plain)

            // Language toggle
            Button {
                withAnimation(.spring(response: 0.35, dampingFraction: 0.7)) {
                    lang.toggle()
                }
            } label: {
                Text(lang.isRTL ? "EN" : "ع")
                    .font(PharmacyColor.sans(13, .semibold))
                    .foregroundColor(PharmacyColor.primary)
                    .frame(width: 36, height: 36)
                    .background(PharmacyColor.primarySoft)
                    .clipShape(Circle())
            }
            .buttonStyle(.plain)
        }
        .padding(.horizontal, PharmacySpacing.md)
        .padding(.vertical, PharmacySpacing.sm)
        .background(PharmacyColor.surface)
        .shadow(color: .black.opacity(0.04), radius: 4, x: 0, y: 2)
    }
}
