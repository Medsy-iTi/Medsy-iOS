//
//  PharmacyOrderItemsSection.swift
//  Medsy
//
//  Created by Shahudaa on 26/07/2026.
//


import SwiftUI

struct PharmacyOrderItemsSection: View {
    let items: [CompletedOrderItemPresentationModel]

    var body: some View {
        VStack(alignment: .leading, spacing: PharmacySpacing.xs) {
            Text("completed_order.items_label".localized)
                .font(PharmacyColor.sans(15, .semibold))
                .foregroundStyle(PharmacyColor.textPrimary)

            VStack(spacing: 0) {
                ForEach(Array(items.enumerated()), id: \.element.id) { index, item in
                    PharmacyOrderItemRow(item: item)
                    if index < items.count - 1 {
                        PharmacyDivider()
                            .padding(.leading, 56 + PharmacySpacing.md)
                    }
                }
            }
            .pharmacyCard(padding: nil)
        }
    }
}

/// A single order line item: thumbnail, name, quantity/price, total.
struct PharmacyOrderItemRow: View {
    let item: CompletedOrderItemPresentationModel

    var body: some View {
        HStack(alignment: .center, spacing: PharmacySpacing.sm) {
            thumbnail
                .frame(width: 56, height: 56)
                .background(PharmacyColor.primarySoft)
                .clipShape(RoundedRectangle(cornerRadius: PharmacyRadius.sm, style: .continuous))

            VStack(alignment: .leading, spacing: 3) {
                Text(item.productName)
                    .font(PharmacyColor.sans(14, .semibold))
                    .foregroundStyle(PharmacyColor.textPrimary)
                    .lineLimit(2)

                Text(String(format: "completed_order.item_qty_price".localized, item.quantity, item.unitPrice))
                    .font(PharmacyColor.sans(12))
                    .foregroundStyle(PharmacyColor.textSecondary)
            }

            Spacer(minLength: 0)

            Text(String(format: "completed_order.price_format".localized, item.totalPrice))
                .font(PharmacyColor.sans(14, .semibold))
                .foregroundStyle(PharmacyColor.textPrimary)
        }
        .padding(.horizontal, PharmacySpacing.md)
        .padding(.vertical, PharmacySpacing.sm)
    }

    @ViewBuilder
    private var thumbnail: some View {
        if let imageUrl = item.imageUrl, let url = URL(string: imageUrl) {
            AsyncImage(url: url) { phase in
                switch phase {
                case .empty:
                    ProgressView()
                case .success(let image):
                    image
                        .resizable()
                        .scaledToFill()
                case .failure:
                    placeholderIcon
                @unknown default:
                    EmptyView()
                }
            }
        } else {
            placeholderIcon
        }
    }

    private var placeholderIcon: some View {
        Image(systemName: "pills.fill")
            .font(.system(size: 22))
            .foregroundStyle(PharmacyColor.primary.opacity(0.7))
    }
}
