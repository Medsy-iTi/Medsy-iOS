//
//  MedsyChatView+NavigationBar.swift
//  Medsy
//

import SwiftUI

extension MedsyChatView {
    var navigationBar: some View {
        HStack(spacing: MedsySpacing.xs) {
            ZStack {
                RoundedRectangle(cornerRadius: MedsyRadius.sm, style: .continuous)
                    .fill(theme.primary)
                Image(systemName: "plus")
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

            Button {
                withAnimation(.spring(response: 0.35, dampingFraction: 0.7)) {
                    lang.toggle()
                }
            } label: {
                Text(lang.isRTL ? "EN" : "ع")
                    .font(MedsyFont.bodyMedium(13))
                    .foregroundColor(AppColor.green)
                    .frame(width: 36, height: 36)
                    .background(AppColor.primaryLight)
                    .clipShape(Circle())
            }
            .buttonStyle(.plain)
        }
        .padding(.horizontal, MedsySpacing.md)
        .padding(.vertical, MedsySpacing.sm)
        .background(AppColor.surface)
        .shadow(color: .black.opacity(0.04), radius: 4, x: 0, y: 2)
    }
}
