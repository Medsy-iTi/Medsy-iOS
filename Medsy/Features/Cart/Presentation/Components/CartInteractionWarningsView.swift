import SwiftUI

struct CartInteractionWarningsView: View {
    let warnings: [CartInteractionWarning]
    let state: CartInteractionsState
    let onRetry: () -> Void

    var body: some View {
        switch state {
        case .idle:
            EmptyView()
        case .loading:
            loadingView
        case .failed:
            failureView
        case .loaded:
            if !warnings.isEmpty {
                warningsView
            }
        }
    }

    private var loadingView: some View {
        HStack(spacing: MedsySpacing.sm) {
            ProgressView()
                .tint(AppColor.green)

            Text("cart.interactions.loading".localized)
                .font(MedsyFont.bodyMedium(14))
                .foregroundStyle(AppColor.textSec)

            Spacer()
        }
        .padding(MedsySpacing.md)
        .background(AppColor.card)
        .clipShape(RoundedRectangle(cornerRadius: MedsyRadius.lg, style: .continuous))
        .overlay(cardBorder)
    }

    private var failureView: some View {
        HStack(spacing: MedsySpacing.sm) {
            Image(systemName: "shield.slash")
                .font(.system(size: 18, weight: .semibold))
                .foregroundStyle(AppColor.warningYellow)

            Text("cart.interactions.failure".localized)
                .font(MedsyFont.caption(13))
                .foregroundStyle(AppColor.textSec)
                .frame(maxWidth: .infinity, alignment: .leading)

            Button("error.retry".localized, action: onRetry)
                .font(MedsyFont.button(13))
                .foregroundStyle(AppColor.green)
                .buttonStyle(.plain)
        }
        .padding(MedsySpacing.md)
        .background(AppColor.card)
        .clipShape(RoundedRectangle(cornerRadius: MedsyRadius.lg, style: .continuous))
        .overlay(cardBorder)
    }

    private var warningsView: some View {
        VStack(alignment: .leading, spacing: MedsySpacing.sm) {
            HStack(alignment: .top, spacing: MedsySpacing.sm) {
                Image(systemName: "shield.lefthalf.filled")
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundStyle(AppColor.green)

                VStack(alignment: .leading, spacing: MedsySpacing.xxs) {
                    Text("cart.interactions.title".localized)
                        .font(MedsyFont.title(17))
                        .foregroundStyle(AppColor.textPrim)

                    Text("cart.interactions.subtitle".localized)
                        .font(MedsyFont.caption(13))
                        .foregroundStyle(AppColor.textSec)
                }
            }

            ForEach(warnings) { warning in
                warningCard(warning)
            }
        }
    }

    private func warningCard(_ warning: CartInteractionWarning) -> some View {
        let style = WarningStyle(severity: warning.severity)

        return VStack(alignment: .leading, spacing: MedsySpacing.sm) {
            HStack(alignment: .top, spacing: MedsySpacing.sm) {
                Image(systemName: style.icon)
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundStyle(style.color)

                VStack(alignment: .leading, spacing: MedsySpacing.xs) {
                    Text(warning.title)
                        .font(MedsyFont.bodyMedium(15))
                        .foregroundStyle(AppColor.textPrim)
                        .frame(maxWidth: .infinity, alignment: .leading)

                    Text(style.labelKey.localized)
                        .font(MedsyFont.button(11))
                        .foregroundStyle(style.color)
                        .padding(.horizontal, MedsySpacing.xs)
                        .padding(.vertical, MedsySpacing.xxs)
                        .background(style.color.opacity(0.12))
                        .clipShape(Capsule())
                }
            }

            if !warning.involvedProducts.isEmpty {
                VStack(alignment: .leading, spacing: MedsySpacing.xs) {
                    ForEach(warning.involvedProducts) { product in
                        HStack(alignment: .top, spacing: MedsySpacing.xs) {
                            Circle()
                                .fill(style.color)
                                .frame(width: 6, height: 6)
                                .padding(.top, 7)

                            VStack(alignment: .leading, spacing: MedsySpacing.xxs) {
                                Text(product.productName)
                                    .font(MedsyFont.bodyMedium(13))
                                    .foregroundStyle(AppColor.textPrim)

                                if !product.ingredient.isEmpty {
                                    Text(product.ingredient)
                                        .font(MedsyFont.caption(12))
                                        .foregroundStyle(AppColor.textSec)
                                }
                            }
                        }
                    }
                }
            }

            if !warning.advice.isEmpty {
                HStack(alignment: .top, spacing: MedsySpacing.xs) {
                    Image(systemName: "info.circle")
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundStyle(style.color)

                    Text(warning.advice)
                        .font(MedsyFont.caption(12))
                        .foregroundStyle(AppColor.textSec)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
            }
        }
        .padding(MedsySpacing.md)
        .background(style.background)
        .clipShape(RoundedRectangle(cornerRadius: MedsyRadius.lg, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: MedsyRadius.lg, style: .continuous)
                .stroke(style.color.opacity(0.35), lineWidth: 1)
        )
        .accessibilityElement(children: .combine)
    }

    private var cardBorder: some View {
        RoundedRectangle(cornerRadius: MedsyRadius.lg, style: .continuous)
            .stroke(AppColor.border, lineWidth: 1)
    }
}

private struct WarningStyle {
    let color: Color
    let background: Color
    let icon: String
    let labelKey: String

    init(severity: CartInteractionSeverity) {
        switch severity {
        case .high:
            color = AppColor.danger
            background = AppColor.dangerLight
            icon = "exclamationmark.triangle.fill"
            labelKey = "cart.interactions.severity.high"
        case .moderate:
            color = AppColor.warningYellow
            background = AppColor.warningLight
            icon = "exclamationmark.circle.fill"
            labelKey = "cart.interactions.severity.moderate"
        }
    }
}
