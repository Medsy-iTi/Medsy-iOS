//
//  PrescriptionReviewMetricCard.swift
//  Medsy
//
//  Created by Ehab Salah on 22/07/2026.
//

import SwiftUI

struct PrescriptionReviewMetricCard: View {
    let value: Int
    let title: String
    let tint: Color
    let background: Color

    var body: some View {
        VStack(spacing: MedsySpacing.xs) {
            Text("\(value)")
                .font(MedsyFont.title(24))
                .foregroundStyle(tint)

            Text(title)
                .font(MedsyFont.caption(12))
                .foregroundStyle(tint)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, MedsySpacing.md)
        .background(background, in: RoundedRectangle(cornerRadius: MedsyRadius.md, style: .continuous))
    }
}
