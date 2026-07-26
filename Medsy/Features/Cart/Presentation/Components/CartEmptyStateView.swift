//
//  CartEmptyStateView.swift
//  Medsy
//
//  Created by Ahmed Elkady on 18/07/2026.
//

import SwiftUI

struct CartEmptyStateView: View {
    let onSearch: () -> Void
    let onScanPrescription: () -> Void

    var body: some View {
        VStack(spacing: MedsySpacing.lg) {
            Spacer(minLength: MedsySpacing.xxl)

            ZStack {
                RoundedRectangle(cornerRadius: 36, style: .continuous)
                    .fill(AppColor.lightGreen)

                Image(systemName: "cart.badge.plus")
                    .font(.system(size: 44, weight: .semibold))
                    .foregroundStyle(AppColor.green)

                MedsyLottieView(animationName: "cart_empty_scan")
                    .frame(width: 144, height: 144)
            }
            .frame(width: 160, height: 160)

            VStack(spacing: MedsySpacing.xs) {
                Text("cart.empty.title".localized)
                    .font(MedsyFont.title(24))
                    .foregroundStyle(AppColor.textPrim)
                    .multilineTextAlignment(.center)

                Text("cart.empty.message".localized)
                    .font(MedsyFont.body(15))
                    .foregroundStyle(AppColor.textSec)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, MedsySpacing.md)
            }

            VStack(spacing: MedsySpacing.sm) {
                PrimaryButton(
                    title: "cart.empty.search".localized,
                    systemImage: "magnifyingglass",
                    action: onSearch
                )

                PrimaryButton(
                    title: "cart.empty.scan_prescription".localized,
                    systemImage: "doc.text.viewfinder",
                    style: .secondary,
                    action: onScanPrescription
                )
            }

            Spacer()
        }
        .padding(.horizontal, MedsySpacing.md)
    }
}
