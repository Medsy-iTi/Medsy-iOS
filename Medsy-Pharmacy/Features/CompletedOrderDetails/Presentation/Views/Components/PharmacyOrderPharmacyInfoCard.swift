//
//  PharmacyOrderPharmacyInfoCard.swift
//  Medsy
//
//  Created by Shahudaa on 26/07/2026.
//


//
//  PharmacyOrderPharmacyInfoCard.swift
//  Medsy-Pharmacy
//
//  Pharmacy name, address, phone, and pharmacist card.
//

import SwiftUI

struct PharmacyOrderPharmacyInfoCard: View {
    let pharmacyName: String
    let pharmacyAddress: String
    let pharmacyPhone: String
    let pharmacistName: String

    var body: some View {
        VStack(alignment: .leading, spacing: PharmacySpacing.sm) {
            HStack(spacing: PharmacySpacing.sm) {
                ZStack {
                    Circle()
                        .fill(PharmacyColor.primarySoft)
                        .frame(width: 44, height: 44)
                    Image(systemName: "cross.vial.fill")
                        .font(.system(size: 18))
                        .foregroundStyle(PharmacyColor.primary)
                }

                VStack(alignment: .leading, spacing: 2) {
                    Text("completed_order.pharmacy".localized)
                        .font(PharmacyColor.sans(12))
                        .foregroundStyle(PharmacyColor.textSecondary)
                    Text(pharmacyName)
                        .font(PharmacyColor.sans(15, .semibold))
                        .foregroundStyle(PharmacyColor.textPrimary)
                }
                Spacer(minLength: 0)
            }

            PharmacyDivider()

            infoRow(systemImage: "mappin.and.ellipse", text: pharmacyAddress)
            infoRow(systemImage: "phone.fill", text: pharmacyPhone)

            if !pharmacistName.isEmpty {
                infoRow(
                    systemImage: "person.fill",
                    text: String(format: "%@: %@", "completed_order.pharmacist".localized, pharmacistName)
                )
            }
        }
        .pharmacyCard()
    }

    private func infoRow(systemImage: String, text: String) -> some View {
        HStack(spacing: PharmacySpacing.sm) {
            Image(systemName: systemImage)
                .font(.system(size: 14))
                .foregroundStyle(PharmacyColor.textSecondary)
                .frame(width: 20)
            Text(text)
                .font(PharmacyColor.sans(14))
                .foregroundStyle(PharmacyColor.textPrimary)
        }
    }
}

#Preview {
    PharmacyOrderPharmacyInfoCard(
        pharmacyName: "Al Shifa Pharmacy",
        pharmacyAddress: "12 Tahrir St, Ismailia",
        pharmacyPhone: "+20 100 000 0000",
        pharmacistName: "Dr. Sara Adel"
    )
    .padding()
    .background(PharmacyColor.bg)
}