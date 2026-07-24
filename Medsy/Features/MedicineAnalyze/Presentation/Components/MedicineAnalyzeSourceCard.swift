//
//  MedicineAnalyzeSourceCard.swift
//  Medsy
//
//  Created by Ehab Salah on 23/07/2026.
//

import SwiftUI

struct MedicineAnalyzeSourceCard: View {
    let icon: String
    let title: String
    let message: String
    let tint: Color
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: MedsySpacing.md) {
                Image(systemName: icon)
                    .font(.system(size: 22, weight: .semibold))
                    .foregroundStyle(tint)
                    .frame(width: 54, height: 54)
                    .background(tint.opacity(0.14), in: Circle())

                VStack(alignment: .leading, spacing: MedsySpacing.xxs) {
                    Text(title)
                        .font(MedsyFont.button(16))
                        .foregroundStyle(AppColor.textPrim)

                    Text(message)
                        .font(MedsyFont.caption(13))
                        .foregroundStyle(AppColor.textSec)
                        .multilineTextAlignment(.leading)
                }

                Spacer(minLength: MedsySpacing.sm)

                Image(systemName: "chevron.forward")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(AppColor.textSec)
            }
            .padding(MedsySpacing.md)
            .background(AppColor.card, in: RoundedRectangle(cornerRadius: MedsyRadius.lg, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: MedsyRadius.lg, style: .continuous)
                    .stroke(AppColor.border, lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
    }
}
