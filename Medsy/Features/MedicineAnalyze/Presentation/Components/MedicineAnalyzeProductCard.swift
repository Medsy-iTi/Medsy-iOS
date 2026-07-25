//
//  MedicineAnalyzeProductCard.swift
//  Medsy
//
//  Created by Ehab Salah on 23/07/2026.
//

import SwiftUI

struct MedicineAnalyzeProductCard: View {
    let product: MedicineAnalyzeProductDisplay
    let quantity: Int
    let onTap: () -> Void
    let onAdd: () -> Void
    let onIncrement: () -> Void
    let onDecrement: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: MedsySpacing.md) {
            HStack(spacing: MedsySpacing.xs) {
                Image(systemName: "sparkles")
                    .font(.system(size: 11, weight: .bold))
                Text("medicineAnalyze.results.match".localized)
                    .font(MedsyFont.caption(11).weight(.semibold))
                Spacer()
                Text(product.consumerCategory)
                    .font(MedsyFont.caption(10).weight(.semibold))
                    .lineLimit(1)
            }
            .foregroundStyle(AppColor.green)

            HStack(alignment: .top, spacing: MedsySpacing.md) {
                Button(action: onTap) {
                    HStack(alignment: .top, spacing: MedsySpacing.md) {
                        MedicineAnalyzeResultThumbnail(imageURL: product.imageURL)

                        VStack(alignment: .leading, spacing: MedsySpacing.xxs) {
                            Text(product.name)
                                .font(MedsyFont.title(15))
                                .foregroundStyle(AppColor.textPrim)
                                .multilineTextAlignment(.leading)
                                .lineLimit(2)

                            if !product.details.isEmpty {
                                Text(product.details)
                                    .font(MedsyFont.caption(12))
                                    .foregroundStyle(AppColor.textSec)
                                    .multilineTextAlignment(.leading)
                            }

                            Text(product.company)
                                .font(MedsyFont.caption(11))
                                .foregroundStyle(AppColor.textSec)
                                .multilineTextAlignment(.leading)
                                .lineLimit(2)
                        }
                    }
                }
                .buttonStyle(.plain)

                Spacer(minLength: 0)

                VStack(alignment: .trailing, spacing: MedsySpacing.sm) {
                    Text("product.price_value".localized(product.price))
                        .font(MedsyFont.price(15))
                        .foregroundStyle(AppColor.green)
                        .lineLimit(1)

                    MedicineAnalyzeQuantityControl(
                        quantity: quantity,
                        onAdd: onAdd,
                        onIncrement: onIncrement,
                        onDecrement: onDecrement
                    )
                }
            }

            Button(action: onTap) {
                HStack {
                    Text(product.scientificName)
                        .font(MedsyFont.caption(11))
                        .foregroundStyle(AppColor.textSec)
                        .lineLimit(1)

                    Spacer()

                    Image(systemName: "chevron.forward")
                        .font(.system(size: 11, weight: .semibold))
                        .foregroundStyle(AppColor.textSec)
                }
                .padding(.top, MedsySpacing.xs)
                .overlay(alignment: .top) {
                    Rectangle()
                        .fill(AppColor.border)
                        .frame(height: 1)
                }
            }
            .buttonStyle(.plain)
        }
        .padding(MedsySpacing.md)
        .background(AppColor.card, in: RoundedRectangle(cornerRadius: MedsyRadius.lg, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: MedsyRadius.lg, style: .continuous)
                .stroke(AppColor.border, lineWidth: 1)
        }
    }
}
