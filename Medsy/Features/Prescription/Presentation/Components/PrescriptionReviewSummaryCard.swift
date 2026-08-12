//
//  PrescriptionReviewSummaryCard.swift
//  Medsy
//
//  Created by Ehab Salah on 22/07/2026.
//

import SwiftUI
import UIKit

struct PrescriptionReviewSummaryCard: View {
    @State private var showsImage = false

    let imageData: Data?
    let totalCount: Int
    let recognizedCount: Int
    let needsReviewCount: Int

    var body: some View {
        VStack(alignment: .leading, spacing: MedsySpacing.md) {
            Text("prescription.review.foundCount".localized(totalCount))
                .font(MedsyFont.title(17))
                .foregroundStyle(AppColor.textPrim)

            HStack(spacing: MedsySpacing.sm) {
                PrescriptionReviewMetricCard(
                    value: recognizedCount,
                    title: "prescription.review.recognized".localized,
                    tint: AppColor.green,
                    background: AppColor.lightGreen.opacity(0.8)
                )

                PrescriptionReviewMetricCard(
                    value: needsReviewCount,
                    title: "prescription.review.needsReview".localized,
                    tint: AppColor.warningYellow,
                    background: Color(hex: "#FEF8E7")
                )
            }

            DisclosureGroup(isExpanded: $showsImage) {
                if let imageData, let image = UIImage(data: imageData) {
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFit()
                        .frame(maxWidth: .infinity, maxHeight: 220)
                        .clipShape(RoundedRectangle(cornerRadius: MedsyRadius.md, style: .continuous))
                        .padding(.top, MedsySpacing.sm)
                } else {
                    Label("prescription.review.noImage".localized, systemImage: "photo")
                        .font(MedsyFont.caption(12))
                        .foregroundStyle(AppColor.textSec)
                        .padding(.top, MedsySpacing.sm)
                }
            } label: {
                Text("prescription.review.showImage".localized)
                    .font(MedsyFont.button(13))
                    .foregroundStyle(AppColor.green)
            }
            .tint(AppColor.green)
            .padding(MedsySpacing.sm)
            .background(AppColor.card, in: RoundedRectangle(cornerRadius: MedsyRadius.md, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: MedsyRadius.md, style: .continuous)
                    .stroke(AppColor.border, lineWidth: 1)
            )
        }
        .padding(MedsySpacing.md)
        .background(AppColor.card, in: RoundedRectangle(cornerRadius: 14, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .stroke(AppColor.border, lineWidth: 1)
        )
    }
}
