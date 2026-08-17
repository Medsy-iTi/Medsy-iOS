//
//  PharmacistCommentCardView.swift
//  Medsy
//
//  Created by Antoneos Philip on 25/07/2026.
//

import SwiftUI

struct PharmacistCommentCardView: View {
    @Environment(LanguageManager.self) private var languageManager
    let comment: String

    var body: some View {
        VStack(alignment: .trailing, spacing: 12) {
            Text("offers.details.pharmacistComment".localized)
                .font(AppColor.sans(16, .bold))
                .foregroundStyle(AppColor.textPrim)
                .padding(.horizontal, 4)

            HStack(alignment: .top, spacing: 12) {
                Text(comment)
                    .font(AppColor.sans(13))
                    .foregroundStyle(AppColor.textPrim)
                    .multilineTextAlignment(.trailing)
                    .lineSpacing(4)
                    .frame(maxWidth: .infinity, alignment: .trailing)

                ZStack {
                    Circle()
                        .fill(AppColor.green.opacity(0.15))
                        .frame(width: 44, height: 44)

                    Image(systemName: "person.crop.circle.fill")
                        .font(.system(size: 26))
                        .foregroundStyle(AppColor.green)
                }
            }
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(AppColor.card)
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(AppColor.border, lineWidth: 1)
                    )
            )
        }
        .environment(\.layoutDirection, languageManager.isRTL ? .rightToLeft : .leftToRight)
    }
}
