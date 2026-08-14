//
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
                    .frame(width: 44, height: 44)
                    .background(PharmacyColor.card, in: Circle())
                    .overlay(Circle().stroke(PharmacyColor.border, lineWidth: 1))
            }
            .buttonStyle(PharmacyPressableButtonStyle())

            Spacer()

            Text("pharmacy.request.details.title".localized)
                .font(PharmacyColor.sans(20, .bold))
                .foregroundStyle(PharmacyColor.textPrimary)

            Spacer()

            Color.clear
                .frame(width: 24, height: 24)
        }
        .padding(.horizontal, PharmacySpacing.md)
        .padding(.vertical, PharmacySpacing.sm)
    }
}
