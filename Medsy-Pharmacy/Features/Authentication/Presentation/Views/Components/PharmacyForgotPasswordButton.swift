//
//  PharmacyForgotPasswordButton.swift
//  Medsy-Pharmacy
//
//  Created by Ehab Salah on 18/08/2026.
//

import SwiftUI

struct PharmacyForgotPasswordButton: View {
    let action: () -> Void

    var body: some View {
        Button("pharmacy.auth.forgot_password".localized, action: action)
            .font(PharmacyColor.sans(13, .semibold))
            .foregroundStyle(PharmacyColor.primary)
            .frame(maxWidth: .infinity, alignment: .trailing)
            .accessibilityHint("pharmacy.auth.password_reset.forgot.accessibility_hint".localized)
    }
}
