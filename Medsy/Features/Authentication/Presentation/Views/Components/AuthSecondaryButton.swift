//
//  AuthSecondaryButton.swift
//  Medsy
//

import SwiftUI

struct AuthSecondaryButton: View {
    let title: String
    let imageName: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 10) {
                Image(imageName)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 20, height: 20)
                    .accessibilityHidden(true)

                Text(title)
                    .font(.subheadline.weight(.medium))
                    .foregroundStyle(AppColor.textPrim)
            }
                .frame(maxWidth: .infinity)
                .frame(height: 54)
                .background(AppColor.card, in: RoundedRectangle(cornerRadius: 14, style: .continuous))
                .overlay {
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .stroke(AppColor.border, lineWidth: 1)
                }
        }
        .accessibilityLabel(title)
    }
}
