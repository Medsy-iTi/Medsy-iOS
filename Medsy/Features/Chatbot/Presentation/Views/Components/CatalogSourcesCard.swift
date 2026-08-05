
//
//  CatalogSourcesCard.swift
//  Medsy
//

import SwiftUI

struct CatalogSourcesCard: View {

    let sources:      [AICatalogSource]
    var onAddToCart:  ((AICatalogSource) -> Void)?
    var onDetails:    ((AICatalogSource) -> Void)?

    private let theme = MedsyTheme.default

    var body: some View {
        VStack(spacing: 0) {
            ForEach(Array(sources.enumerated()), id: \.element.id) { index, source in
                MedsyProductCard(
                    eyebrow:             eyebrow(for: source),
                    name:                source.product.displayName,
                    subtitle:            subtitle(for: source),
                    price:               source.product.formattedPrice,
                    badgeText:           matchBadge(for: source),
                    badgeColor:          badgeColor(for: source),
                    primaryButtonTitle:  "chatbot.action.add_to_cart".localized,
                    secondaryButtonTitle: "chatbot.action.details".localized,
                    accentColor:         theme.primary,
                    cardBackground:      AppColor.card,
                    onPrimaryTap:        { onAddToCart?(source) },
                    onSecondaryTap:      { onDetails?(source) }
                )

                if index < sources.count - 1 {
                    Divider()
                        .background(AppColor.border)
                        .padding(.horizontal, MedsySpacing.md)
                }
            }
        }
        .clipShape(RoundedRectangle(cornerRadius: MedsyRadius.lg, style: .continuous))
        .medsyCardShadow()
    }

    // MARK: - Helpers

    private func eyebrow(for source: AICatalogSource) -> String? {
        "chatbot.sources.eyebrow".localized
    }

    private func subtitle(for source: AICatalogSource) -> String {
        let detail = source.product.detailLine
        if !detail.isEmpty { return detail }
        return source.product.scientificName ?? source.product.company ?? ""
    }

    private func matchBadge(for source: AICatalogSource) -> String? {
        guard source.score > 0 else { return nil }
        return String(format: "chatbot.sources.match".localized, source.scorePercentage)
    }

    private func badgeColor(for source: AICatalogSource) -> Color {
        source.score >= 0.80
            ? AppColor.successGreen
            : AppColor.warningYellow
    }
}
