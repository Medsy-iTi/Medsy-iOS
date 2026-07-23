//
//  PharmacyRequestDetailsBottomBar.swift
//  Medsy-Pharmacy
//
//  Created by Antoneos Philip on 23/07/2026.
//

import SwiftUI

struct PharmacyRequestDetailsBottomBar: View {
    let onAccept: () -> Void
    let onReject: () -> Void
    let onContact: () -> Void

    var body: some View {
        VStack(spacing: PharmacySpacing.xs) {
            HStack(spacing: PharmacySpacing.sm) {
                Button(action: onReject) {
                    HStack(spacing: 6) {
                        Image(systemName: "xmark")
                            .font(.system(size: 13, weight: .bold))
                        Text("pharmacy.request.reject_order_btn".localized)
                            .font(PharmacyColor.sans(14, .bold))
                    }
                    .foregroundStyle(PharmacyColor.danger)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .background(PharmacyColor.card, in: RoundedRectangle(cornerRadius: PharmacyRadius.md, style: .continuous))
                    .overlay(
                        RoundedRectangle(cornerRadius: PharmacyRadius.md, style: .continuous)
                            .stroke(PharmacyColor.danger.opacity(0.5), lineWidth: 1)
                    )
                }
                .buttonStyle(.plain)

                Button(action: onContact) {
                    HStack(spacing: 6) {
                        Text("pharmacy.request.contact_customer_btn".localized)
                            .font(PharmacyColor.sans(14, .bold))
                        Image(systemName: "text.bubble")
                            .font(.system(size: 14, weight: .medium))
                    }
                    .foregroundStyle(PharmacyColor.primary)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .background(PharmacyColor.card, in: RoundedRectangle(cornerRadius: PharmacyRadius.md, style: .continuous))
                    .overlay(
                        RoundedRectangle(cornerRadius: PharmacyRadius.md, style: .continuous)
                            .stroke(PharmacyColor.border, lineWidth: 1)
                    )
                }
                .buttonStyle(.plain)
            }

            Button(action: onAccept) {
                HStack(spacing: 8) {
                    Text("pharmacy.request.accept_order_btn".localized)
                        .font(PharmacyColor.sans(16, .bold))
                    Image(systemName: "checkmark")
                        .font(.system(size: 15, weight: .bold))
                }
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 14)
                .background(PharmacyColor.primary, in: RoundedRectangle(cornerRadius: PharmacyRadius.md, style: .continuous))
            }
            .buttonStyle(.plain)
        }
        .padding(.horizontal, PharmacySpacing.md)
        .padding(.vertical, PharmacySpacing.sm)
        .background(PharmacyColor.bg)
    }
}
