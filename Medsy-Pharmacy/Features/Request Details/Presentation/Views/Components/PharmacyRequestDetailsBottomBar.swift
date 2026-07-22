//  PharmacyRequestDetailsBottomBar.swift
//  Medsy-Pharmacy
//
//  Created by Antoneos Philip on 23/07/2026.
//

import SwiftUI

struct PharmacyRequestDetailsBottomBar: View {
    let onAccept: () -> Void
    let onReject: () -> Void

    var body: some View {
        HStack(spacing: PharmacySpacing.md) {
            Button(action: onReject) {
                Text("pharmacy.request.reject".localized)
                    .font(PharmacyColor.sans(15, .bold))
                    .foregroundStyle(PharmacyColor.danger)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .background(PharmacyColor.card, in: RoundedRectangle(cornerRadius: PharmacyRadius.md, style: .continuous))
                    .overlay(
                        RoundedRectangle(cornerRadius: PharmacyRadius.md, style: .continuous)
                            .stroke(PharmacyColor.danger, lineWidth: 1.5)
                    )
            }
            .buttonStyle(.plain)

            Button(action: onAccept) {
                Text("pharmacy.request.accept".localized)
                    .font(PharmacyColor.sans(15, .bold))
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .background(PharmacyColor.primary, in: RoundedRectangle(cornerRadius: PharmacyRadius.md, style: .continuous))
            }
            .buttonStyle(.plain)
        }
        .padding(.horizontal, PharmacySpacing.md)
        .padding(.vertical, PharmacySpacing.sm)
        .background(PharmacyColor.surface)
    }
}
