//
//  OrderPharmacySectionView.swift
//  Medsy
//
//  Created by Ahmed Elkady on 14/08/2026.
//

import SwiftUI

struct OrderPharmacySectionView: View {
    let pharmacy: OrderPharmacyPresentationModel
    let onSelect: () -> Void

    var body: some View {
        Button(action: onSelect) {
            HStack(spacing: MedsySpacing.sm) {
                Image("PharmacySnakeIcon")
                    .renderingMode(.template)
                    .resizable()
                    .scaledToFit()
                    .foregroundStyle(AppColor.green)
                    .frame(width: 24, height: 24)
                    .frame(width: 40, height: 40)
                    .background(AppColor.primaryContainer)
                    .clipShape(Circle())

                VStack(alignment: .leading, spacing: 2) {
                    Text("orders.detail.pharmacy".localized)
                        .font(AppColor.sans(12))
                        .foregroundStyle(AppColor.textSec)

                    Text(pharmacy.name)
                        .font(AppColor.sans(16, .bold))
                        .foregroundStyle(AppColor.textPrim)
                        .lineLimit(2)
                }

                Spacer()

                Image(systemName: "chevron.forward")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(AppColor.textSec)
            }
            .padding(MedsySpacing.md)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(AppColor.card)
            .clipShape(RoundedRectangle(cornerRadius: MedsyRadius.lg, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: MedsyRadius.lg, style: .continuous)
                    .stroke(AppColor.outline.opacity(0.15), lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
        .accessibilityLabel("orders.detail.pharmacy".localized + ", " + pharmacy.name)
    }
}
