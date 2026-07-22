//  OfferMedicinesCardView.swift
//  Medsy
//
//  Created by Antoneos Philip on 22/07/2026.

import SwiftUI

struct OfferMedicinesCardView: View {
    let medicines: [OfferMedicineItem]

    var body: some View {
        VStack(alignment: .trailing, spacing: 12) {
            Text("الأدوية المطلوبة")
                .font(AppColor.sans(16, .bold))
                .foregroundStyle(AppColor.textPrim)
                .padding(.horizontal, 4)

            VStack(spacing: 0) {
                ForEach(Array(medicines.enumerated()), id: \.element.id) { index, item in
                    OfferMedicineItemRow(item: item)

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
    }
}
