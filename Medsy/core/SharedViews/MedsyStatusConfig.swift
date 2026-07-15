//
//  MedsyStatusConfig.swift
//  Medsy
//
//  Created by Shahudaa on 15/07/2026.
//

import SwiftUI

struct MedsyStatusConfig {
    let systemIcon: String
    let iconColor: Color
    let iconBackground: Color
    let title: String
    let subtitle: String
    let primaryButtonTitle: String
    var primaryAction: () -> Void
    var secondaryButtonTitle: String? = nil
    var secondaryAction: (() -> Void)? = nil

    static func noResults(onClear: @escaping () -> Void, onPrescription: @escaping () -> Void) -> MedsyStatusConfig {
        MedsyStatusConfig(
            systemIcon: "magnifyingglass",
			iconColor: .primary,
			iconBackground: .secondary,
            title: NSLocalizedString("empty.title", comment: ""),
            subtitle: NSLocalizedString("empty.subtitle", comment: ""),
            primaryButtonTitle: NSLocalizedString("empty.clear_search", comment: ""),
            primaryAction: onClear,
            secondaryButtonTitle: NSLocalizedString("empty.request_prescription", comment: ""),
            secondaryAction: onPrescription
        )
    }

    static func noConnection(onRetry: @escaping () -> Void) -> MedsyStatusConfig {
        MedsyStatusConfig(
            systemIcon: "wifi.slash",
            iconColor: AppColor.danger,
            iconBackground: AppColor.danger.opacity(0.12),
            title: NSLocalizedString("error.no_connection_title", comment: ""),
            subtitle: NSLocalizedString("error.no_connection_subtitle", comment: ""),
            primaryButtonTitle: NSLocalizedString("error.retry", comment: ""),
            primaryAction: onRetry
        )
    }
}

struct MedsyStatusView: View {
	let config: MedsyStatusConfig

	var body: some View {
		VStack(spacing: MedsySpacing.lg) {
			Spacer(minLength: MedsySpacing.xxl)

			ZStack {
				Circle()
					.fill(config.iconBackground)
					.frame(width: 96, height: 96)
				Image(systemName: config.systemIcon)
					.font(.system(size: 34, weight: .medium))
					.foregroundStyle(config.iconColor)
			}

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

			VStack(spacing: MedsySpacing.sm) {
				MedsyPrimaryButton(title: config.primaryButtonTitle, action: config.primaryAction)
					.padding(.horizontal, MedsySpacing.xl)

				if let secondaryTitle = config.secondaryButtonTitle, let secondaryAction = config.secondaryAction {
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


