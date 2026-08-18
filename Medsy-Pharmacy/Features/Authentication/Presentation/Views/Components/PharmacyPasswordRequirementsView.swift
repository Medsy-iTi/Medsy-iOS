//
//  PharmacyPasswordRequirementsView.swift
//  Medsy-Pharmacy
//
//  Created by Ehab Salah on 18/08/2026.
//

import SwiftUI

struct PharmacyPasswordRequirementsView: View {
    var body: some View {
        Label(
            "pharmacy.auth.password_reset.requirements".localized,
            systemImage: "info.circle"
        )
        .font(PharmacyColor.sans(13))
        .foregroundStyle(PharmacyColor.textSecondary)
        .frame(maxWidth: .infinity, alignment: .leading)
        .fixedSize(horizontal: false, vertical: true)
    }
}
