//
//  PaymentStatusView.swift
//  Medsy
//
//  Created by Ahmed Elkady on 02/08/2026.
//

import SwiftUI

struct PaymentStatusView: View {
    @Environment(LanguageManager.self) private var languageManager
    @ObservedObject private var appSettings = AppSettings.shared

    let status: PaymentStatusPresentation
    var isPrimaryActionLoading = false
    var isPrimaryActionDisabled = false
    let onPrimaryAction: () -> Void
    let onSecondaryAction: () -> Void

    var body: some View {
        VStack(spacing: MedsySpacing.lg) {
            Spacer()

            PaymentStatusArtworkView(status: status)

            VStack(spacing: MedsySpacing.sm) {
                Text(status.title)
                    .font(AppColor.sans(22, .bold))
                    .foregroundStyle(AppColor.textPrim)
                    .multilineTextAlignment(.center)

                Text(status.message)
                    .font(MedsyFont.body())
                    .foregroundStyle(AppColor.textSec)
                    .multilineTextAlignment(.center)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .padding(.horizontal, MedsySpacing.xl)
            .accessibilityElement(children: .combine)

            if status == .processing {
                Label(
                    "payment.status.processing.notice".localized,
                    systemImage: "info.circle.fill"
                )
                .font(MedsyFont.caption(12))
                .foregroundStyle(AppColor.textSec)
                .padding(MedsySpacing.md)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(AppColor.card)
                .clipShape(RoundedRectangle(cornerRadius: MedsyRadius.lg))
                .padding(.horizontal, MedsySpacing.md)
            }

            Spacer()

            VStack(spacing: MedsySpacing.sm) {
                PrimaryButton(
                    title: status.primaryActionTitle,
                    isLoading: isPrimaryActionLoading,
                    isDisabled: isPrimaryActionDisabled,
                    action: onPrimaryAction
                )

                if status.showsSecondaryAction {
                    PrimaryButton(
                        title: "payment.action.view_order".localized,
                        style: .secondary,
                        action: onSecondaryAction
                    )
                }
            }
            .padding(.horizontal, MedsySpacing.md)
            .padding(.bottom, MedsySpacing.lg)
        }
        .background(AppColor.bg.ignoresSafeArea())
        .localizedEnvironment()
        .id(languageManager.currentLanguage)
        .preferredColorScheme(appSettings.isDarkMode ? .dark : .light)
        .navigationBarBackButtonHidden()
    }
}

#Preview("Processing") {
    PaymentStatusView(
        status: .processing,
        onPrimaryAction: {},
        onSecondaryAction: {}
    )
    .environment(LanguageManager.shared)
}

#Preview("Failed") {
    PaymentStatusView(
        status: .failure(message: nil),
        onPrimaryAction: {},
        onSecondaryAction: {}
    )
    .environment(LanguageManager.shared)
}

#Preview("Unsupported") {
    PaymentStatusView(
        status: .unsupportedCombinedOrder,
        onPrimaryAction: {},
        onSecondaryAction: {}
    )
    .environment(LanguageManager.shared)
}
