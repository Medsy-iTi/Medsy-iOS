//
//  CompleteRequestOptionCard.swift
//  Medsy
//
//  Created by Ehab Salah on 24/07/2026.
//

import SwiftUI

struct CompleteRequestOptionCard: View {
    let title: String
    let subtitle: String
    let systemImage: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(alignment: .leading, spacing: MedsySpacing.sm) {
                HStack {
                    Image(systemName: systemImage)
                        .font(.system(size: 20, weight: .semibold))
                        .foregroundStyle(isSelected ? AppColor.green : AppColor.textSec)

                    Spacer()

                    Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                        .font(.system(size: 21, weight: .semibold))
                        .foregroundStyle(isSelected ? AppColor.green : AppColor.textSec)
                }

                Text(title)
                    .font(MedsyFont.bodyMedium())
                    .foregroundStyle(AppColor.textPrim)

                Text(subtitle)
                    .font(MedsyFont.caption())
                    .foregroundStyle(AppColor.textSec)
                    .multilineTextAlignment(.leading)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            .padding(MedsySpacing.sm)
            .frame(maxWidth: .infinity, minHeight: 138, alignment: .topLeading)
            .background(isSelected ? AppColor.pill : AppColor.card)
            .clipShape(RoundedRectangle(cornerRadius: MedsyRadius.lg))
            .overlay {
                RoundedRectangle(cornerRadius: MedsyRadius.lg)
                    .stroke(isSelected ? AppColor.green : AppColor.border, lineWidth: isSelected ? 2 : 1)
            }
        }
        .buttonStyle(.plain)
        .accessibilityAddTraits(isSelected ? .isSelected : [])
    }
}
