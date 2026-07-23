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

                    HStack(alignment: .center, spacing: 14) {
                        ZStack {
                            RoundedRectangle(cornerRadius: PharmacyRadius.sm, style: .continuous)
                                .fill(Color(white: 0.94))
                                .frame(width: 32, height: 32)

                            Text("\(item.quantity)")
                                .font(PharmacyColor.sans(14, .bold))
                                .foregroundStyle(PharmacyColor.textPrimary)
                        }

                        VStack(alignment: .leading, spacing: 4) {
                            Text(item.name)
                                .font(PharmacyColor.sans(15, .bold))
                                .foregroundStyle(PharmacyColor.textPrimary)

                            Text("\(Int(item.price)) \("pharmacy.request.currency_unit".localized)")
                                .font(PharmacyColor.sans(14, .bold))
                                .foregroundStyle(PharmacyColor.textPrimary)
                        }

                        Spacer()

                        ZStack {
                            RoundedRectangle(cornerRadius: PharmacyRadius.md, style: .continuous)
                                .fill(PharmacyColor.primarySoft.opacity(0.6))
                                .frame(width: 56, height: 56)

                            Image(systemName: "pill.fill")
                                .font(.system(size: 22))
                                .foregroundStyle(PharmacyColor.primary.opacity(0.4))
                        }
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
