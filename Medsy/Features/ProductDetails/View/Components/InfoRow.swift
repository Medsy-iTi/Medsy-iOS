//
//  InfoRow.swift
//  Medsy
//
//  Created by Shahudaa on 15/07/2026.
//

import SwiftUI

struct InfoRow: View {
    let icon: String
    let label: String
    let value: String
    var valueColor: MedsyRowTint = .primary

    @Environment(LanguageManager.self) private var languageManager
    @ObservedObject private var appSettings = AppSettings.shared

    private var valueTint: Color {
        switch valueColor {
        case .primary: return AppColor.textPrim
        case .danger:  return AppColor.danger
        }
    }

    var body: some View {
        HStack(spacing: MedsySpacing.xs) {
          
            Text(label)
                .font(MedsyFont.body(14))
                .foregroundStyle(AppColor.textSec)

            Spacer()


            HStack(spacing: MedsySpacing.xxs) {
                Image(systemName: icon)
                    .foregroundStyle(valueTint)
                    .imageScale(.small)
                Text(value)
                    .font(MedsyFont.bodyMedium(14))
                    .foregroundStyle(valueTint)
            }
        }
        .padding(.vertical, MedsySpacing.xs)
    }
}

// MARK: - Card container

struct MedsyInfoCard<Content: View>: View {
    @ViewBuilder var content: () -> Content
    @ObservedObject private var appSettings = AppSettings.shared

    var body: some View {
        VStack(spacing: 0) {
            content()
        }
        .padding(.horizontal, MedsySpacing.md)
        .background(AppColor.card)
        .clipShape(RoundedRectangle(cornerRadius: MedsyRadius.md))
        .overlay(
            RoundedRectangle(cornerRadius: MedsyRadius.md)
                .stroke(AppColor.border, lineWidth: 1)
        )
    }
}

// MARK: - Row list

struct MedsyInfoRowList: View {
    let rows: [ProductInfoRow]

    var body: some View {
        MedsyInfoCard {
            ForEach(Array(rows.enumerated()), id: \.element.id) { index, row in
                InfoRow(
                    icon: row.icon,
                    label: row.label.localized,
                    value: row.value,
                    valueColor: row.valueColor
                )
                if index < rows.count - 1 {
                    Divider().overlay(AppColor.border)
                }
            }
        }
    }
}
