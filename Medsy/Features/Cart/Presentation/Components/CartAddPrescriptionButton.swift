//
//  CartAddPrescriptionButton.swift
//  Medsy
//
//  Created by Ahmed Elkady on 14/08/2026.
//

import SwiftUI

struct CartAddPrescriptionButton: View {
    let action: () -> Void

    @ObservedObject private var appSettings = AppSettings.shared

    var body: some View {
        Button(action: action) {
            HStack(spacing: MedsySpacing.sm) {
                Image(systemName: "doc.text")
                    .font(.system(size: 18, weight: .semibold))

                Text("cart.prescription.add".localized)
                    .font(MedsyFont.button(15))
            }
            .foregroundStyle(AppColor.textPrim)
            .frame(maxWidth: .infinity)
            .frame(height: 48)
            .background(AppColor.card)
            .overlay {
                RoundedRectangle(cornerRadius: MedsyRadius.sm, style: .continuous)
                    .stroke(AppColor.border, lineWidth: 1)
            }
            .clipShape(RoundedRectangle(cornerRadius: MedsyRadius.sm, style: .continuous))
        }
        .buttonStyle(.plain)
        .accessibilityLabel("cart.prescription.add".localized)
    }
}
