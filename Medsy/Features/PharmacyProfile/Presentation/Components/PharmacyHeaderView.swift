//  PharmacyHeaderView.swift
//  Medsy
//
//  Created by Antoneos Philip on 20/07/2026.

import SwiftUI

struct PharmacyHeaderView: View {
    let name: String

    var body: some View {
        VStack(spacing: 0) {
            ZStack(alignment: .bottomLeading) {
                LinearGradient(
                    colors: [AppColor.green.opacity(0.85), AppColor.darkGreen],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .frame(height: 140)
                .clipShape(RoundedRectangle(cornerRadius: MedsyRadius.lg))

                Circle()
                    .fill(AppColor.surface)
                    .frame(width: 80, height: 80)
                    .shadow(color: .black.opacity(0.1), radius: 6, x: 0, y: 3)
                    .overlay {
                        Image(systemName: "cross.case.fill")
                            .font(.system(size: 38, weight: .bold))
                            .foregroundStyle(AppColor.green)
                    }
                    .offset(x: MedsySpacing.md, y: 40)
            }
            .padding(.bottom, 44)

            VStack(alignment: .leading, spacing: MedsySpacing.xs) {
                HStack(alignment: .center) {
                    Text(name)
                        .font(MedsyFont.title(22))
                        .foregroundStyle(AppColor.textPrim)

                    Spacer()

                    HStack(spacing: 4) {
                        Image(systemName: "checkmark.seal.fill")
                            .font(.system(size: 14, weight: .bold))
                        Text("pharmacyProfile.badge".localized)
                            .font(MedsyFont.caption(12))
                    }
                    .foregroundStyle(AppColor.green)
                    .padding(.horizontal, MedsySpacing.xs)
                    .padding(.vertical, MedsySpacing.xxs)
                    .background(AppColor.pill)
                    .clipShape(Capsule())
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }
}
