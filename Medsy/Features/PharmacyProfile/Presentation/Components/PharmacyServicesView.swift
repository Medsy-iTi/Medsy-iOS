//  PharmacyServicesView.swift
//  Medsy
//
//  Created by Antoneos Philip on 20/07/2026.

import SwiftUI

struct PharmacyServicesView: View {
    private let services: [(title: String, icon: String, color: Color)] = [
        ("Prescriptions", "doc.text.fill", AppColor.green),
        ("Fast Delivery", "bolt.fill", AppColor.darkGreen),
        ("Insurance", "shield.checkmark.fill", AppColor.green),
        ("Consultation", "heart.text.square.fill", AppColor.darkGreen)
    ]

    var body: some View {
        VStack(alignment: .leading, spacing: MedsySpacing.sm) {
            Text("Pharmacy Services")
                .font(MedsyFont.title(16))
                .foregroundStyle(AppColor.textPrim)

            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: MedsySpacing.xs) {
                ForEach(services, id: \.title) { item in
                    HStack(spacing: MedsySpacing.xs) {
                        Image(systemName: item.icon)
                            .font(.system(size: 14, weight: .bold))
                            .foregroundStyle(item.color)
                            .frame(width: 28, height: 28)
                            .background(AppColor.pill)
                            .clipShape(Circle())

                        Text(item.title)
                            .font(MedsyFont.caption(12))
                            .fontWeight(.medium)
                            .foregroundStyle(AppColor.textPrim)

                        Spacer()
                    }
                    .padding(MedsySpacing.xs)
                    .background(AppColor.bg)
                    .clipShape(RoundedRectangle(cornerRadius: MedsyRadius.sm))
                }
            }
        }
        .padding(MedsySpacing.md)
        .background(AppColor.card)
        .clipShape(RoundedRectangle(cornerRadius: MedsyRadius.lg))
        .overlay(
            RoundedRectangle(cornerRadius: MedsyRadius.lg)
                .stroke(AppColor.border, lineWidth: 1)
        )
    }
}
