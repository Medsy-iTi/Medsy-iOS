//
//  PrescriptionReviewBlockingBanner.swift
//  Medsy
//
//  Created by Ehab Salah on 22/07/2026.
//

import SwiftUI

struct PrescriptionReviewBlockingBanner: View {
    var body: some View {
        HStack(spacing: MedsySpacing.sm) {
            Image(systemName: "exclamationmark.triangle")
                .font(.system(size: 14, weight: .semibold))
                .foregroundStyle(AppColor.warningYellow)

            Text("prescription.review.blocked".localized)
                .font(MedsyFont.caption(12))
                .foregroundStyle(AppColor.warningYellow)

            Spacer()
        }
        .padding(.horizontal, MedsySpacing.md)
        .padding(.vertical, MedsySpacing.sm)
        .background(Color(hex: "#FFF8E1"), in: RoundedRectangle(cornerRadius: MedsyRadius.md, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: MedsyRadius.md, style: .continuous)
                .stroke(Color(hex: "#FDE68A"), lineWidth: 1)
        )
    }
}
