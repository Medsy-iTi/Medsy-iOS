//
//  WarningBanner.swift
//  Medsy
//
//  Created by Shahudaa on 15/07/2026.
//

import SwiftUI

struct WarningBanner: View {
    let text: String
    var icon: String = "checkmark.shield"
    var iconColor: Color = AppColor.green

    @Environment(LanguageManager.self) private var languageManager
    @ObservedObject private var appSettings = AppSettings.shared

    var body: some View {
        HStack(alignment: .top, spacing: MedsySpacing.sm) {
            iconBadge
            textView
        }
        .padding(MedsySpacing.sm)
        .background(AppColor.warningBg)
        .overlay(
            RoundedRectangle(cornerRadius: MedsyRadius.md)
                .stroke(AppColor.warningBorder.opacity(0.4), lineWidth: 1)
        )
        .clipShape(RoundedRectangle(cornerRadius: MedsyRadius.md))

    }

    private var textView: some View {
        Text(text)
            .font(MedsyFont.caption(13))
            .foregroundStyle(AppColor.textPrim)
            .multilineTextAlignment(.leading)
            .frame(maxWidth: .infinity, alignment: .leading)
    }

    private var iconBadge: some View {
        Image(systemName: icon)
            .foregroundStyle(iconColor)
            .imageScale(.medium)
    }
}
