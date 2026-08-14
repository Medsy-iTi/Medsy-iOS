//
//  CompleteRequestSectionCard.swift
//  Medsy
//
//  Created by Ehab Salah on 24/07/2026.
//

import SwiftUI

struct CompleteRequestSectionCard<Content: View>: View {
    let title: String
    let systemImage: String
    let backgroundColor: Color
    let titleColor: Color
    let iconColor: Color
    let iconBackgroundColor: Color
    let borderColor: Color
    let shadowColor: Color
    @ViewBuilder let content: () -> Content

    init(
        title: String,
        systemImage: String,
        backgroundColor: Color = AppColor.card,
        titleColor: Color = AppColor.textPrim,
        iconColor: Color = AppColor.green,
        iconBackgroundColor: Color = AppColor.pill,
        borderColor: Color = AppColor.border,
        shadowColor: Color = AppSettings.shared.isDarkMode ? .clear : AppColor.green.opacity(0.06),
        @ViewBuilder content: @escaping () -> Content
    ) {
        self.title = title
        self.systemImage = systemImage
        self.backgroundColor = backgroundColor
        self.titleColor = titleColor
        self.iconColor = iconColor
        self.iconBackgroundColor = iconBackgroundColor
        self.borderColor = borderColor
        self.shadowColor = shadowColor
        self.content = content
    }

    var body: some View {
        VStack(alignment: .leading, spacing: MedsySpacing.md) {
            Label {
                Text(title)
                    .font(MedsyFont.title())
                    .foregroundStyle(titleColor)
            } icon: {
                Image(systemName: systemImage)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(iconColor)
                    .frame(width: 38, height: 38)
                    .background(iconBackgroundColor)
                    .clipShape(Circle())
            }

            content()
        }
        .padding(MedsySpacing.md)
        .background(backgroundColor)
        .clipShape(RoundedRectangle(cornerRadius: MedsyRadius.lg, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: MedsyRadius.lg, style: .continuous)
                .stroke(borderColor, lineWidth: 1)
        }
        .shadow(
            color: shadowColor,
            radius: 10,
            y: 4
        )
    }
}
