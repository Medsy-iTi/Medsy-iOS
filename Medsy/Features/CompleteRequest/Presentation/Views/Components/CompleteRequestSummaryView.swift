//
//  CompleteRequestSummaryView.swift
//  Medsy
//
//  Created by Ehab Salah on 24/07/2026.
//

import SwiftUI

struct CompleteRequestSummaryView: View {
    @Environment(\.colorScheme) private var colorScheme
    let draft: CompleteRequestDraft
    @Binding var isExpanded: Bool

    var body: some View {
        CompleteRequestSectionCard(
            title: "complete_request.summary.title".localized,
            systemImage: "list.clipboard",
            backgroundColor: sectionBackgroundColor,
            titleColor: primaryTextColor,
            iconColor: accentColor,
            iconBackgroundColor: iconBackgroundColor,
            borderColor: borderColor,
            shadowColor: colorScheme == .dark ? .clear : AppColor.green.opacity(0.06)
        ) {
            VStack(spacing: MedsySpacing.sm) {
                HStack {
                    Text(summaryCountText)
                        .font(MedsyFont.body())
                        .foregroundStyle(secondaryTextColor)

                    Spacer()

                    Text(formattedPrice(draft.estimatedTotal))
                        .font(MedsyFont.price(18))
                        .foregroundStyle(primaryTextColor)
                }

                if !draft.items.isEmpty {
                    Button {
                        withAnimation(.easeInOut(duration: 0.2)) {
                            isExpanded.toggle()
                        }
                    } label: {
                        HStack {
                            Text(
                                isExpanded
                                    ? "complete_request.summary.hide_items".localized
                                    : "complete_request.summary.show_items".localized
                            )
                            Spacer()
                            Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                        }
                        .font(MedsyFont.bodyMedium(14))
                        .foregroundStyle(accentColor)
                    }
                    .buttonStyle(.plain)
                }

                if isExpanded {
                    Divider().background(borderColor)

                    ForEach(draft.items) { item in
                        HStack(alignment: .center, spacing: MedsySpacing.sm) {
                            MedsyRemoteImage(urlString: item.imageURL, contentMode: .fit) {
                                MedsyBrandImageFallback()
                            } failure: {
                                MedsyBrandImageFallback()
                            }
                            .frame(width: 44, height: 44)
                            .background(itemImageBackgroundColor)
                            .clipShape(RoundedRectangle(cornerRadius: MedsyRadius.sm, style: .continuous))

                            Text("\(item.quantity)×")
                                .font(MedsyFont.bodyMedium(14))
                                .foregroundStyle(accentColor)

                            VStack(alignment: .leading, spacing: MedsySpacing.xxs) {
                                Text(item.name)
                                    .font(MedsyFont.bodyMedium(14))
                                    .foregroundStyle(primaryTextColor)

                                if !item.dosageInfo.isEmpty {
                                    Text(item.dosageInfo)
                                        .font(MedsyFont.caption(12))
                                        .foregroundStyle(secondaryTextColor)
                                }
                            }

                            Spacer()

                            Text(formattedPrice(item.lineTotal))
                                .font(MedsyFont.price(14))
                                .foregroundStyle(primaryTextColor)
                        }
                    }
                }
            }
        }
    }

    private var sectionBackgroundColor: Color {
        colorScheme == .dark ? Color(hex: "#0E1418") : Color(hex: "#FFFFFF")
    }

    private var itemImageBackgroundColor: Color {
        colorScheme == .dark ? Color(hex: "#10161A") : Color(hex: "#FFFFFF")
    }

    private var primaryTextColor: Color {
        colorScheme == .dark ? Color(hex: "#E1E6E3") : Color(hex: "#181C19")
    }

    private var secondaryTextColor: Color {
        colorScheme == .dark ? Color(hex: "#BEC9C2") : Color(hex: "#414943")
    }

    private var accentColor: Color {
        colorScheme == .dark ? Color(hex: "#27C779") : Color(hex: "#048C4E")
    }

    private var iconBackgroundColor: Color {
        colorScheme == .dark ? Color(hex: "#123D2B") : Color(hex: "#D6F5E2")
    }

    private var borderColor: Color {
        colorScheme == .dark ? Color(hex: "#3C4741") : Color(hex: "#C0C9C2")
    }

    private var summaryCountText: String {
        var parts: [String] = []
        if draft.itemCount > 0 {
            parts.append("complete_request.summary.items_count".localized(draft.itemCount))
        }
        if draft.prescriptionCount > 0 {
            parts.append("complete_request.summary.prescriptions_count".localized(draft.prescriptionCount))
        }
        return parts.joined(separator: " • ")
    }

    private func formattedPrice(_ value: Double) -> String {
        String(format: "%.2f %@", value, "cart.currency".localized)
    }
}
