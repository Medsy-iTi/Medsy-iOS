//
//  CartEmptyStateView.swift
//  Medsy
//
//  Created by Ahmed Elkady on 18/07/2026.
//

import SwiftUI

struct CartEmptyStateView: View {
    let onSearch: () -> Void

    var body: some View {
        VStack(spacing: MedsySpacing.sm) {
            Spacer(minLength: MedsySpacing.xxl)

            MedsyLottieView(
                animationName: "cart_empty_medicine",
                animationSpeed: 1.15
            )
            .frame(width: 220, height: 220)
            .accessibilityHidden(true)

            VStack(spacing: MedsySpacing.xs) {
                Text("cart.empty.title".localized)
                    .font(MedsyFont.title(20))
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

            }

            Spacer()
        }
        .padding(.horizontal, MedsySpacing.md)
    }
}
