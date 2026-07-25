//  OfferMedicineItemRow.swift
//  Medsy
//
//  Created by Antoneos Philip on 22/07/2026.

import SwiftUI

struct OfferMedicineItemRow: View {
    @Environment(LanguageManager.self) private var languageManager
    let item: OfferMedicineItem

    var body: some View {
        HStack(alignment: .center, spacing: 12) {
            VStack(alignment: .leading, spacing: 6) {
                VStack(alignment: .leading, spacing: 1) {
                    Text(item.price.truncatingRemainder(dividingBy: 1) == 0 ? "\(Int(item.price))" : String(format: "%.2f", item.price))
                        .font(AppColor.sans(16, .bold))
                        .foregroundStyle(AppColor.textPrim)

                    Text("offers.list.currency".localized)
                        .font(AppColor.sans(11))
                        .foregroundStyle(AppColor.textSec)
                }

                HStack(spacing: 4) {
                    Image(systemName: item.isAvailable ? "checkmark.circle.fill" : "xmark.circle.fill")
                        .font(.system(size: 13, weight: .bold))
                        .foregroundStyle(item.isAvailable ? AppColor.green : AppColor.danger)

                    Text(item.isAvailable ? "offers.details.available".localized : "offers.details.unavailable".localized)
                        .font(AppColor.sans(11, .bold))
                        .foregroundStyle(item.isAvailable ? AppColor.green : AppColor.danger)
                }
            }

            Spacer()

            VStack(alignment: .trailing, spacing: 4) {
                HStack(spacing: 6) {
                    if item.isAlternative {
                        Text("Alternative")
                            .font(AppColor.sans(10, .bold))
                            .foregroundStyle(AppColor.badgePurple)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(AppColor.badgePurple.opacity(0.12))
                            .clipShape(Capsule())
                    }

                    Text(item.name)
                        .font(AppColor.sans(15, .bold))
                        .foregroundStyle(AppColor.textPrim)
                        .multilineTextAlignment(.trailing)
                }

                if !item.dosage.isEmpty {
                    Text(item.dosage)
                        .font(AppColor.sans(12))
                        .foregroundStyle(AppColor.textSec)
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

                if let imageUrl = item.imageUrl, let url = URL(string: imageUrl) {
                    AsyncImage(url: url) { image in
                        image
                            .resizable()
                            .scaledToFit()
                            .padding(6)
                    } placeholder: {
                        Image(systemName: item.imageName)
                            .font(.system(size: 22))
                            .foregroundStyle(AppColor.green)
                    }
                } else {
                    Image(systemName: item.imageName)
                        .font(.system(size: 22))
                        .foregroundStyle(AppColor.green)
                }
            }
            .frame(width: 52, height: 52)
        }
        .environment(\.layoutDirection, languageManager.isRTL ? .rightToLeft : .leftToRight)
        .padding(.vertical, 10)
        .padding(.horizontal, 16)
    }
}
