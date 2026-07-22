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
    let onToggleAlternative: (String) -> Void

    var body: some View {
        VStack(alignment: .trailing, spacing: PharmacySpacing.sm) {
            HStack(spacing: 8) {
                Spacer()

                Text("تفاصيل الطلب")
                    .font(PharmacyColor.sans(15, .bold))
                    .foregroundStyle(PharmacyColor.textPrimary)

                Image(systemName: "bag")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(PharmacyColor.primary)
            }

            VStack(spacing: 12) {
                ForEach(items.indices, id: \.self) { index in
                    let item = items[index]
                    
                    VStack(alignment: .trailing, spacing: 6) {
                        HStack(alignment: .center, spacing: 12) {
                            Text("\(item.quantity) × \(Int(item.price))")
                                .font(PharmacyColor.sans(14, .bold))
                                .foregroundStyle(PharmacyColor.textPrimary)

                            Spacer()

                            VStack(alignment: .trailing, spacing: 2) {
                                Text(item.name)
                                    .font(PharmacyColor.sans(14, .bold))
                                    .foregroundStyle(item.isAvailable ? PharmacyColor.textPrimary : PharmacyColor.danger)

                                Text(item.spec)
                                    .font(PharmacyColor.sans(12, .medium))
                                    .foregroundStyle(PharmacyColor.textSecondary)
                            }

                            ZStack {
                                RoundedRectangle(cornerRadius: PharmacyRadius.sm, style: .continuous)
                                    .fill(PharmacyColor.mutedSurface)
                                    .frame(width: 44, height: 44)

                                Image(systemName: "pill.fill")
                                    .font(.system(size: 20))
                                    .foregroundStyle(PharmacyColor.primary)
                            }
                        }

                        HStack {
                            Button(action: {
                                onToggleAlternative(item.id)
                            }) {
                                HStack(spacing: 4) {
                                    Image(systemName: item.isAvailable ? "exclamationmark.triangle" : "arrow.triangle.2.circlepath")
                                        .font(.system(size: 11, weight: .bold))
                                    Text(item.isAvailable ? "غير متوفر / إضافة بديل" : (item.alternativeMedicine ?? "تم تحديد بديل"))
                                        .font(PharmacyColor.sans(11, .semibold))
                                }
                                .foregroundStyle(item.isAvailable ? PharmacyColor.warning : PharmacyColor.secondary)
                                .padding(.horizontal, 10)
                                .padding(.vertical, 5)
                                .background(item.isAvailable ? PharmacyColor.warningSoft : PharmacyColor.secondarySoft, in: Capsule())
                            }
                            .buttonStyle(.plain)

                            Spacer()
                        }
                    }

                    if index < items.count - 1 {
                        Divider()
                            .overlay(PharmacyColor.border)
                    }
                }
            }
            .padding(.vertical, 4)

            Divider()
                .overlay(PharmacyColor.border)

            VStack(spacing: 8) {
                HStack {
                    Text("\(Int(deliveryFee)) جنيه")
                        .font(PharmacyColor.sans(13, .semibold))
                        .foregroundStyle(PharmacyColor.textPrimary)

                    Spacer()

                    Text("رسوم التوصيل")
                        .font(PharmacyColor.sans(13, .medium))
                        .foregroundStyle(PharmacyColor.textSecondary)
                }

                HStack {
                    Text("\(Int(total)) جنيه")
                        .font(PharmacyColor.sans(16, .bold))
                        .foregroundStyle(PharmacyColor.primary)

                    Spacer()

                    Text("الإجمالي")
                        .font(PharmacyColor.sans(16, .bold))
                        .foregroundStyle(PharmacyColor.textPrimary)
                }
            }
            .padding(.top, 4)
        }
        .padding(PharmacySpacing.md)
        .background(PharmacyColor.card, in: RoundedRectangle(cornerRadius: PharmacyRadius.lg, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: PharmacyRadius.lg, style: .continuous)
                .stroke(PharmacyColor.border, lineWidth: 1)
        )
    }
}
