//
//  FavoriteMedicineCardSkeleton.swift
//  Medsy
//
//  Created by Ehab Salah on 13/08/2026.
//

import SwiftUI

struct FavoriteMedicineCardSkeleton: View {
    var body: some View {
        VStack(alignment: .leading, spacing: MedsySpacing.xs) {
            block(height: 126, radius: MedsyRadius.md)
            block(height: 16)
            block(height: 16, width: 110)
            block(height: 12, width: 82)
            Spacer(minLength: 0)
            block(height: 18, width: 72)
            block(height: 42, radius: MedsyRadius.md)
        }
        .padding(MedsySpacing.sm)
        .frame(maxWidth: .infinity, minHeight: 310, alignment: .topLeading)
        .background {
            RoundedRectangle(cornerRadius: MedsyRadius.lg, style: .continuous)
                .fill(AppColor.card)
                .overlay {
                    RoundedRectangle(cornerRadius: MedsyRadius.lg, style: .continuous)
                        .stroke(AppColor.border, lineWidth: 1)
                }
        }
    }

    private func block(height: CGFloat, width: CGFloat? = nil, radius: CGFloat = MedsyRadius.sm) -> some View {
        MedsyShimmerBlock(cornerRadius: radius).frame(width: width, height: height)
    }
}
