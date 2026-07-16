//
//  MedsyBanner.swift
//  Medsy
//
//  Created by Shahudaa on 15/07/2026.
//


import SwiftUI

struct WarningBanner: View {
    let text: String
    var icon: String = "checkmark.shield"
    var iconColor: Color = AppColor.green
    var background: Color = AppColor.warningBg
    var borderColor: Color = AppColor.warningBorder

    @Environment(LanguageManager.self) private var languageManager

    var body: some View {
        HStack(spacing: MedsySpacing.sm) {
            if languageManager.isRTL {
                iconBadge
                textView
            } else {
                textView
                iconBadge
            }
        }
        .padding(MedsySpacing.sm)
        .background(background)
        .overlay(
            RoundedRectangle(cornerRadius: MedsyRadius.md)
                .stroke(borderColor.opacity(0.4), lineWidth: 1)
        )
        .clipShape(RoundedRectangle(cornerRadius: MedsyRadius.md))
    }

    private var textView: some View {
        Text(text)
            .font(MedsyFont.caption(13))
            .foregroundStyle(AppColor.textPrim)
            .multilineTextAlignment(languageManager.isRTL ? .trailing : .leading)
            .frame(maxWidth: .infinity, alignment: languageManager.isRTL ? .trailing : .leading)
    }

    private var iconBadge: some View {
        Image(systemName: icon)
            .foregroundStyle(iconColor)
            .imageScale(.medium)
    }
}

