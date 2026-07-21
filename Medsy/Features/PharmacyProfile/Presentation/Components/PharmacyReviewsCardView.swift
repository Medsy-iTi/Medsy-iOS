//  PharmacyReviewsCardView.swift
//  Medsy
//
//  Created by Antoneos Philip on 20/07/2026.

import SwiftUI

struct PharmacyReviewsCardView: View {
    var body: some View {
        VStack(alignment: .leading, spacing: MedsySpacing.sm) {
            HStack {
                Text("Ratings & Reviews")
                    .font(MedsyFont.title(16))
                    .foregroundStyle(AppColor.textPrim)

                Spacer()

                HStack(spacing: 3) {
                    Image(systemName: "star.fill")
                        .font(.system(size: 14))
                        .foregroundStyle(AppColor.warningYellow)

                    Text("4.9")
                        .font(MedsyFont.price(14))
                        .foregroundStyle(AppColor.textPrim)
                }
            }

            VStack(alignment: .leading, spacing: MedsySpacing.xs) {
                HStack {
                    Text("Ahmed K.")
                        .font(MedsyFont.bodyMedium(13))
                        .foregroundStyle(AppColor.textPrim)

                    Spacer()

                    HStack(spacing: 2) {
                        ForEach(0..<5) { _ in
                            Image(systemName: "star.fill")
                                .font(.system(size: 10))
                                .foregroundStyle(AppColor.warningYellow)
                        }
                    }
                }

                Text("\"Very fast medicine delivery, genuine products, and super polite pharmacist!\"")
                    .font(MedsyFont.caption(12))
                    .foregroundStyle(AppColor.textSec)
                    .italic()
            }
            .padding(MedsySpacing.sm)
            .background(AppColor.bg)
            .clipShape(RoundedRectangle(cornerRadius: MedsyRadius.md))
        }
        .padding(MedsySpacing.md)
        .background(AppColor.card)
        .clipShape(RoundedRectangle(cornerRadius: MedsyRadius.lg))
        .overlay(
            RoundedRectangle(cornerRadius: MedsyRadius.lg)
                .stroke(AppColor.border, lineWidth: 1)
        )
    }
}
