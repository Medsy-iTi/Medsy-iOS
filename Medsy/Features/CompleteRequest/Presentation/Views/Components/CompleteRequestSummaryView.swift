//
//  CompleteRequestSummaryView.swift
//  Medsy
//
//  Created by Ehab Salah on 24/07/2026.
//

import SwiftUI

struct CompleteRequestSummaryView: View {
    let draft: CompleteRequestDraft
    @Binding var isExpanded: Bool

    var body: some View {
        CompleteRequestSectionCard(
            title: "complete_request.summary.title".localized,
            systemImage: "list.clipboard"
        ) {
            VStack(spacing: MedsySpacing.sm) {
                HStack {
                    Text(summaryCountText)
                        .font(MedsyFont.body())
                        .foregroundStyle(AppColor.textSec)

                    Spacer()

                    Text(formattedPrice(draft.estimatedTotal))
                        .font(MedsyFont.price(18))
                        .foregroundStyle(AppColor.textPrim)
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
                        .foregroundStyle(AppColor.green)
                    }
                    .buttonStyle(.plain)
                }

                if isExpanded {
                    Divider().background(AppColor.border)

                    ForEach(draft.items) { item in
                        HStack(alignment: .center, spacing: MedsySpacing.sm) {
                            MedsyRemoteImage(urlString: item.imageURL, contentMode: .fit) {
                                MedsyBrandImageFallback()
                            } failure: {
                                MedsyBrandImageFallback()
                            }
                            .frame(width: 44, height: 44)
                            .background(AppColor.surface)
                            .clipShape(RoundedRectangle(cornerRadius: MedsyRadius.sm, style: .continuous))

                            Text("\(item.quantity)×")
                                .font(MedsyFont.bodyMedium(14))
                                .foregroundStyle(AppColor.green)

                            VStack(alignment: .leading, spacing: MedsySpacing.xxs) {
                                Text(item.name)
                                    .font(MedsyFont.bodyMedium(14))
                                    .foregroundStyle(AppColor.textPrim)

                                if !item.dosageInfo.isEmpty {
                                    Text(item.dosageInfo)
                                        .font(MedsyFont.caption(12))
                                        .foregroundStyle(AppColor.textSec)
                                }
                            }

                            Spacer()

                            Text(formattedPrice(item.lineTotal))
                                .font(MedsyFont.price(14))
                                .foregroundStyle(AppColor.textPrim)
                        }
                    }
                }
            }
        }
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
