//  PharmacyRequestDetailsHeaderView.swift
//  Medsy-Pharmacy
//
//  Created by Antoneos Philip on 23/07/2026.
//

import SwiftUI

struct PharmacyRequestDetailsHeaderView: View {
    let orderId: String
    let statusTitle: String
    let onBack: () -> Void

    var body: some View {
        HStack(alignment: .center) {
            Button(action: onBack) {
                Image(systemName: "arrow.backward")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundStyle(PharmacyColor.textPrimary)
                    .padding(8)
            }
            .buttonStyle(.plain)

            Spacer()

            VStack(spacing: 2) {
                Text("تفاصيل الطلب")
                    .font(PharmacyColor.sans(18, .bold))
                    .foregroundStyle(PharmacyColor.textPrimary)

                Text("#\(orderId)")
                    .font(PharmacyColor.sans(15, .bold))
                    .foregroundStyle(PharmacyColor.textPrimary)
            }

            Spacer()

            Text(statusTitle)
                .font(PharmacyColor.sans(12, .semibold))
                .foregroundStyle(PharmacyColor.primary)
                .padding(.horizontal, 14)
                .padding(.vertical, 6)
                .background(PharmacyColor.primarySoft, in: Capsule())
        }
        .padding(.horizontal, PharmacySpacing.md)
        .padding(.vertical, PharmacySpacing.xs)
    }
}
