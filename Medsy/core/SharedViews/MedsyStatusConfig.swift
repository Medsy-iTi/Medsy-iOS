//
//  MedsyStatusConfig.swift
//  Medsy
//
//  Created by Shahudaa on 15/07/2026.
//

import SwiftUI

// MARK: - Config

struct MedsyStatusConfig {
    let systemIcon: String
    // Use closures so colors are re-evaluated on every render (theme-reactive)
    let iconColor: () -> Color
    let iconBackground: () -> Color
    let title: String
    let subtitle: String
    let primaryButtonTitle: String
    var primaryAction: () -> Void
    var secondaryButtonTitle: String? = nil
    var secondaryAction: (() -> Void)? = nil

    // MARK: - Search: no results
    static func noResults(
        onClear: @escaping () -> Void,
        onPrescription: @escaping () -> Void
    ) -> MedsyStatusConfig {
        MedsyStatusConfig(
            systemIcon: "magnifyingglass",
            iconColor: { AppColor.textSec },
            iconBackground: { AppColor.surface },
            title: "empty.title".localized,
            subtitle: "empty.subtitle".localized,
            primaryButtonTitle: "empty.clear_search".localized,
            primaryAction: onClear,
            secondaryButtonTitle: "empty.request_prescription".localized,
            secondaryAction: onPrescription
        )
    }

    // MARK: - Network error / no connection
    static func noConnection(onRetry: @escaping () -> Void) -> MedsyStatusConfig {
        MedsyStatusConfig(
            systemIcon: "wifi.slash",
            iconColor: { AppColor.danger },
            iconBackground: { AppColor.danger.opacity(0.12) },
            title: "error.no_connection_title".localized,
            subtitle: "error.no_connection_subtitle".localized,
            primaryButtonTitle: "error.retry".localized,
            primaryAction: onRetry
        )
    }

    // MARK: - Product detail: not found / empty
    static func productNotFound(onSearch: @escaping () -> Void) -> MedsyStatusConfig {
        MedsyStatusConfig(
            systemIcon: "magnifyingglass.circle",
            iconColor: { AppColor.textSec },
            iconBackground: { AppColor.surface },
            title: "product.not_found_title".localized,
            subtitle: "product.not_found_subtitle".localized,
            primaryButtonTitle: "product.try_search".localized,
            primaryAction: onSearch
        )
    }

    // MARK: - Product detail: load error
    static func productError(onRetry: @escaping () -> Void) -> MedsyStatusConfig {
        MedsyStatusConfig(
            systemIcon: "exclamationmark.triangle",
            iconColor: { AppColor.danger },
            iconBackground: { AppColor.danger.opacity(0.12) },
            title: "product.error_title".localized,
            subtitle: "product.error_subtitle".localized,
            primaryButtonTitle: "error.retry".localized,
            primaryAction: onRetry
        )
    }
}

// MARK: - Status View

struct MedsyStatusView: View {
    let config: MedsyStatusConfig
    @ObservedObject private var appSettings = AppSettings.shared

    var body: some View {
        VStack(spacing: MedsySpacing.lg) {
            Spacer(minLength: MedsySpacing.xxl)

            // Icon badge — colors evaluated here so theme changes re-render correctly
            ZStack {
                Circle()
                    .fill(config.iconBackground())
                    .frame(width: 96, height: 96)
                Image(systemName: config.systemIcon)
                    .font(.system(size: 34, weight: .medium))
                    .foregroundStyle(config.iconColor())
            }

            // Texts
            VStack(spacing: MedsySpacing.xs) {
                Text(config.title)
                    .font(MedsyFont.title(18))
                    .foregroundStyle(AppColor.textPrim)
                Text(config.subtitle)
                    .font(MedsyFont.body(14))
                    .foregroundStyle(AppColor.textSec)
                    .multilineTextAlignment(.center)
            }
            .padding(.horizontal, MedsySpacing.xl)

            // Buttons
            VStack(spacing: MedsySpacing.sm) {
                PrimaryButton(title: config.primaryButtonTitle, action: config.primaryAction)
                    .padding(.horizontal, MedsySpacing.xl)

                if let secondaryTitle = config.secondaryButtonTitle,
                   let secondaryAction = config.secondaryAction {
                    Button(action: secondaryAction) {
                        Text(secondaryTitle)
                            .font(MedsyFont.bodyMedium(14))
                            .foregroundStyle(AppColor.textPrim)
                    }
                }
            }

            Spacer(minLength: MedsySpacing.xxl)
        }
        .frame(maxWidth: .infinity)
    }
}
