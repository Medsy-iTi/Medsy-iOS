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
    @ViewBuilder let content: () -> Content

    var body: some View {
        VStack(alignment: .leading, spacing: MedsySpacing.md) {
            Label {
                Text(title)
                    .font(MedsyFont.title())
                    .foregroundStyle(AppColor.textPrim)
            } icon: {
                Image(systemName: systemImage)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(AppColor.green)
                    .frame(width: 38, height: 38)
                    .background(AppColor.pill)
                    .clipShape(Circle())
            }

            content()
        }
        .padding(MedsySpacing.md)
        .background(AppColor.card)
        .clipShape(RoundedRectangle(cornerRadius: MedsyRadius.lg, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: MedsyRadius.lg, style: .continuous)
                .stroke(AppColor.border, lineWidth: 1)
        }
    }
}
