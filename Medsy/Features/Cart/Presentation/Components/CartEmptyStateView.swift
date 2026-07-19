//
//  CartEmptyStateView.swift
//  Medsy
//
//  Created by Ahmed Elkady on 18/07/2026.
//

import SwiftUI

struct CartEmptyStateView: View {
    let onSearch: () -> Void
    let onUploadPrescription: () -> Void

    var body: some View {
        VStack(spacing: MedsySpacing.lg) {
            Spacer(minLength: MedsySpacing.xxl)

            ZStack {
                Circle()
                    .fill(AppColor.lightGreen)

                Image(systemName: "cart")
                    .font(.system(size: 44, weight: .semibold))
                    .foregroundStyle(AppColor.green)
            }
            .frame(width: 112, height: 112)

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
                    title: "cart.empty.upload".localized,
                    systemImage: "camera",
                    style: .secondary,
                    action: onUploadPrescription
                )
            }

            Spacer()
        }
        .padding(.horizontal, MedsySpacing.md)
    }
}
