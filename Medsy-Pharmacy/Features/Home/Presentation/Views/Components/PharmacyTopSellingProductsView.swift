//
//  PharmacyTopSellingProductsView.swift
//  Medsy-Pharmacy
//

import SwiftUI

struct PharmacyTopSellingProductsView: View {
    let products: [PharmacyHomeTopProduct]

    var body: some View {
        VStack(alignment: .leading, spacing: PharmacySpacing.sm) {
            Text("pharmacy.home.top_selling_products".localized)
                .font(PharmacyColor.sans(16, .bold))
                .foregroundStyle(PharmacyColor.textPrimary)

            Group {
                if products.isEmpty {
                    PharmacyHomeSectionMessage(
                        icon: "shippingbox",
                        title: "pharmacy.home.products_empty_title".localized,
                        message: "pharmacy.home.products_empty_message".localized
                    )
                } else {
                    VStack(spacing: 0) {
                        ForEach(Array(products.enumerated()), id: \.element.id) { index, product in
                            PharmacyTopSellingProductRow(product: product)

                            if index < products.count - 1 {
                                Divider()
                                    .overlay(PharmacyColor.border)
                                    .padding(.leading, 76)
                            }
                        }
                    }
                }
            }
            .pharmacyCard(cornerRadius: PharmacyRadius.md, padding: nil, elevation: .subtle)
        }
    }
}

private struct PharmacyTopSellingProductRow: View {
    let product: PharmacyHomeTopProduct

    var body: some View {
        HStack(spacing: PharmacySpacing.sm) {
            AsyncImage(url: product.imageUrl) { phase in
                switch phase {
                case .success(let image):
                    image
                        .resizable()
                        .scaledToFill()
                default:
                    Image(systemName: "pills.fill")
                        .font(.system(size: 20, weight: .semibold))
                        .foregroundStyle(PharmacyColor.primary)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .background(PharmacyColor.primarySoft)
                }
            }
            .frame(width: 52, height: 52)
            .clipShape(RoundedRectangle(cornerRadius: PharmacyRadius.sm, style: .continuous))

            VStack(alignment: .leading, spacing: PharmacySpacing.xxs) {
                Text(product.name)
                    .font(PharmacyColor.sans(13, .semibold))
                    .foregroundStyle(PharmacyColor.textPrimary)
                    .lineLimit(2)

                Text("pharmacy.home.quantity_sold".localized(product.quantitySold))
                    .font(PharmacyColor.sans(11, .medium))
                    .foregroundStyle(PharmacyColor.textSecondary)
            }

            Spacer(minLength: PharmacySpacing.xs)

            Text(
                product.revenue,
                format: .currency(code: "EGP")
                    .precision(.fractionLength(0...2))
            )
            .font(PharmacyColor.sans(12, .bold))
            .foregroundStyle(PharmacyColor.success)
            .multilineTextAlignment(.trailing)
        }
        .padding(PharmacySpacing.sm)
        .accessibilityElement(children: .combine)
    }
}
