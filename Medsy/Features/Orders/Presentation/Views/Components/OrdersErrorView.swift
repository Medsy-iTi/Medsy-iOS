//
//  OrdersErrorView.swift
//  Medsy
//
//  Created by Ahmed Elkady on 21/07/2026.
//

import SwiftUI

struct OrdersErrorView: View {
    let message: String
    let onRetry: () -> Void

    var body: some View {
        VStack(spacing: MedsySpacing.lg) {
            Image(systemName: "wifi.exclamationmark")
                .font(.system(size: 48, weight: .light))
                .foregroundStyle(AppColor.errorRed.opacity(0.7))

            VStack(spacing: MedsySpacing.xs) {
                Text("orders.error.title".localized)
                    .font(MedsyFont.title(17))
                    .foregroundStyle(AppColor.textPrim)
                    .multilineTextAlignment(.center)

                Text(message.isEmpty ? "orders.error.subtitle".localized : message)
                    .font(MedsyFont.caption())
                    .foregroundStyle(AppColor.textSec)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, MedsySpacing.xl)
            }

            Button("common.retry".localized, action: onRetry)
                .font(AppColor.sans(15, .semibold))
                .foregroundStyle(AppColor.white)
                .padding(.horizontal, MedsySpacing.xxl)
                .padding(.vertical, MedsySpacing.sm)
                .background(AppColor.green)
                .clipShape(Capsule())
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(.bottom, MedsySpacing.xxl)
    }
}

#Preview {
    OrdersErrorView(message: "orders.error.subtitle".localized, onRetry: {})
        .background(AppColor.bg)
}
