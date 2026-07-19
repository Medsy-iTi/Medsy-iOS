//
//  RatingStarsView.swift
//  Medsy
//
//  Created by Shahudaa on 18/07/2026.
//


import SwiftUI

struct RatingStarsView: View {
    let rating: Double
    let ratingCount: Int

    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: "star.fill")
                .font(.system(size: 12))
                .foregroundStyle(PharmacyColor.warning)
            Text(String(format: "%.1f", rating))
                .font(PharmacyColor.sans(13, .bold))
                .foregroundStyle(PharmacyColor.textPrimary)
            Text("(\(ratingCount) \("rating_count_suffix".localized))")
                .font(PharmacyColor.sans(12))
                .foregroundStyle(PharmacyColor.textSecondary)
        }
        .accessibilityElement(children: .combine)
    }
}
