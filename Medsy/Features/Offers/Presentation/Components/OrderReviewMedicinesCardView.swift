//  OrderReviewMedicinesCardView.swift
//  Medsy
//
//  Created by Antoneos Philip on 22/07/2026.

import SwiftUI

struct OrderReviewMedicineRow: View {
    @Environment(LanguageManager.self) private var languageManager
    let item: OfferMedicineItem

    private func formatAmount(_ amount: Double) -> String {
        amount.truncatingRemainder(dividingBy: 1) == 0 ? "\(Int(amount))" : String(format: "%.2f", amount)
    }

    var body: some View {
        HStack(alignment: .center, spacing: 12) {
            Text("\(formatAmount(item.price)) \("offers.list.currency".localized)")
                .font(AppColor.sans(15, .bold))
                .foregroundStyle(AppColor.textPrim)

            Spacer()

            VStack(alignment: .trailing, spacing: 4) {
                Text(item.name.isEmpty ? "offers.details.unavailableItem".localized : item.name)
                    .font(AppColor.sans(15, .bold))
                    .foregroundStyle(AppColor.textPrim)
                    .multilineTextAlignment(.trailing)

                if !item.dosage.isEmpty {
                    Text(item.dosage)
                        .font(AppColor.sans(12))
                        .foregroundStyle(AppColor.textSec)
                        .multilineTextAlignment(.trailing)
                }

                Text(String(format: "orderReview.medicine.quantity".localized, item.quantity))
                    .font(AppColor.sans(12))
                    .foregroundStyle(AppColor.textSec)
                    .multilineTextAlignment(.trailing)

                if let supplier = item.supplierName, !supplier.isEmpty {
                    Text(String(format: "orderReview.medicine.suppliedBy".localized, supplier))
                        .font(AppColor.sans(12, .medium))
                        .foregroundStyle(AppColor.green)
                        .multilineTextAlignment(.trailing)
                }
            }

            ZStack {
                RoundedRectangle(cornerRadius: 12)
                    .fill(AppColor.surface)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(AppColor.border, lineWidth: 1)
                    )

                MedsyRemoteImage(urlString: item.imageUrl, contentMode: .fit) {
                    Image(systemName: item.imageName)
                        .font(.system(size: 22))
                        .foregroundStyle(AppColor.green)
                } failure: {
                    Image(systemName: item.imageName)
                        .font(.system(size: 22))
                        .foregroundStyle(AppColor.green)
                }
                .padding(6)
            }
            .frame(width: 52, height: 52)
        }
        .environment(\.layoutDirection, languageManager.isRTL ? .rightToLeft : .leftToRight)
        .padding(.vertical, 10)
        .padding(.horizontal, 16)
    }
}

struct OrderReviewMedicinesCardView: View {
    @Environment(LanguageManager.self) private var languageManager
    let medicines: [OfferMedicineItem]

    var body: some View {
        VStack(alignment: .trailing, spacing: 12) {
            Text("orderReview.section.medicines".localized)
                .font(AppColor.sans(16, .bold))
                .foregroundStyle(AppColor.textPrim)
                .padding(.horizontal, 4)

            VStack(spacing: 0) {
                ForEach(Array(medicines.enumerated()), id: \.element.id) { index, item in
                    OrderReviewMedicineRow(item: item)

                    if index < medicines.count - 1 {
                        Divider()
                            .background(AppColor.border)
                            .padding(.horizontal, 16)
                    }
                }
            }
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(AppColor.card)
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(AppColor.border, lineWidth: 1)
                    )
            )
        }
        .environment(\.layoutDirection, languageManager.isRTL ? .rightToLeft : .leftToRight)
    }
}
