//
//  PharmacyOrderItemsCard.swift
//  Medsy-Pharmacy
//
//  Created by Antoneos Philip on 23/07/2026.
//

import SwiftUI

struct PharmacyOrderItemsCard: View {
    @Binding var items: [PharmacyOrderItem]
    let deliveryFee: Double
    let total: Double

    var body: some View {
        VStack(alignment: .leading, spacing: PharmacySpacing.xs) {
            Text("pharmacy.request.requested_medicines".localized)
                .font(PharmacyColor.sans(16, .bold))
                .foregroundStyle(PharmacyColor.textPrimary)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.bottom, 2)

            VStack(spacing: 0) {
                ForEach(Array(items.enumerated()), id: \.element.id) { index, item in
                    if index > 0 {
                        Divider()
                            .overlay(PharmacyColor.border)
                            .padding(.vertical, 12)
                    }

                    VStack(alignment: .leading, spacing: 10) {
                        HStack(alignment: .center, spacing: 14) {
                            ZStack {
                                RoundedRectangle(cornerRadius: PharmacyRadius.md, style: .continuous)
                                    .fill(PharmacyColor.primarySoft.opacity(0.6))
                                    .frame(width: 56, height: 56)

                                if let imageUrlStr = item.imageUrl, let url = URL(string: imageUrlStr) {
                                    AsyncImage(url: url) { image in
                                        image
                                            .resizable()
                                            .scaledToFill()
                                            .frame(width: 56, height: 56)
                                            .clipShape(RoundedRectangle(cornerRadius: PharmacyRadius.md, style: .continuous))
                                    } placeholder: {
                                        ProgressView()
                                    }
                                } else {
                                    Image(systemName: "pill.fill")
                                        .font(.system(size: 22))
                                        .foregroundStyle(PharmacyColor.primary.opacity(0.4))
                                }
                            }

                            VStack(alignment: .leading, spacing: 4) {
                                Text(item.name)
                                    .font(PharmacyColor.sans(15, .bold))
                                    .foregroundStyle(PharmacyColor.textPrimary)

                                Text("\(item.quantity) x \(Int(item.price)) \("pharmacy.request.currency_unit".localized)")
                                    .font(PharmacyColor.sans(14, .bold))
                                    .foregroundStyle(PharmacyColor.textSecondary)
                            }

                            Spacer()

                            ZStack {
                                RoundedRectangle(cornerRadius: PharmacyRadius.sm, style: .continuous)
                                    .fill(PharmacyColor.primary.opacity(0.1))
                                    .frame(width: 36, height: 36)

                                Image(systemName: item.isAvailable ? "checkmark.circle.fill" : "circle")
                                    .font(.system(size: 20))
                                    .foregroundStyle(item.isAvailable ? PharmacyColor.primary : PharmacyColor.textSecondary)
                            }
                        }

                        HStack(spacing: 8) {
                            Image(systemName: "box.truck.fill")
                                .font(.system(size: 13))
                                .foregroundStyle(PharmacyColor.primary)
                            Text("منتج العرض: \(item.name)")
                                .font(PharmacyColor.sans(13, .semibold))
                                .foregroundStyle(PharmacyColor.primary)
                            Spacer()
                            Text("ID: \(item.selectedOfferProductId)")
                                .font(PharmacyColor.sans(12, .medium))
                                .foregroundStyle(PharmacyColor.textSecondary)
                        }
                        .padding(.horizontal, 10)
                        .padding(.vertical, 6)
                        .background(PharmacyColor.primarySoft.opacity(0.3), in: RoundedRectangle(cornerRadius: PharmacyRadius.sm))
                    }
                }
            }
            .padding(PharmacySpacing.md)
            .background(PharmacyColor.card, in: RoundedRectangle(cornerRadius: PharmacyRadius.lg, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: PharmacyRadius.lg, style: .continuous)
                    .stroke(PharmacyColor.border, lineWidth: 1)
            )
        }
    }
}
