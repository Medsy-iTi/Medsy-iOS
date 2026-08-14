//
//  MedsyChatView+NavigationBar.swift
//  Medsy
//
//  Created by Ahmed Elkady on 12/08/2026.
//

import SwiftUI

extension MedsyChatView {
    var navigationBar: some View {
        HStack(spacing: MedsySpacing.xs) {
            if let onBack {
                MedsyNavBarBackButton(action: onBack)
            }

            // AI avatar
            ZStack {
                RoundedRectangle(cornerRadius: MedsyRadius.sm, style: .continuous)
                    .fill(theme.primary)
                Image(systemName: "sparkles")
                    .foregroundColor(.white)
                    .font(.system(size: 14, weight: .bold))
            }
            .frame(width: 34, height: 34)

            VStack(alignment: .leading, spacing: 1) {
                Text("chatbot.ai.name".localized)
                    .font(MedsyFont.bodyMedium(15))
                    .foregroundColor(AppColor.textPrim)
                HStack(spacing: 4) {
                    Circle()
                        .fill(AppColor.successGreen)
                        .frame(width: 6, height: 6)
                    Text("chatbot.ai.status.online".localized)
                        .font(MedsyFont.caption(11))
                        .foregroundColor(AppColor.successGreen)
                }
            }

            Spacer()

            // New chat button — only confirm if there are messages to clear
            Button {
                if viewModel.messages.isEmpty {
                    viewModel.startNewChat()
                } else {
                    showNewChatConfirmation = true
                }
            } label: {
                Image(systemName: "square.and.pencil")
                    .foregroundColor(AppColor.textSec)
                    .frame(width: 36, height: 36)
                    .background(AppColor.surface)
                    .clipShape(Circle())
            }
            .buttonStyle(.plain)

            // Dark mode toggle
            Button {
                withAnimation(.spring(response: 0.35, dampingFraction: 0.7)) {
                    appSettings.isDarkMode.toggle()
                }
            } label: {
                Image(systemName: appSettings.isDarkMode ? "sun.max.fill" : "moon.fill")
                    .foregroundColor(AppColor.textSec)
                    .frame(width: 36, height: 36)
                    .background(AppColor.surface)
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
                    .font(MedsyFont.bodyMedium(13))
                    .foregroundColor(AppColor.onPrimaryContainer)
                    .frame(width: 36, height: 36)
                    .background(AppColor.primaryLight)
                    .clipShape(Circle())
            }
            .buttonStyle(.plain)
        }
        .padding(.horizontal, MedsySpacing.md)
        .padding(.vertical, MedsySpacing.sm)
        .background(AppColor.surface)
        .overlay(alignment: .bottom) {
            Divider().background(AppColor.border)
        }
    }
}
