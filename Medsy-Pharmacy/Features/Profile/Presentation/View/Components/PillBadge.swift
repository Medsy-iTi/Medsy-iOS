//
//  PillBadge.swift
//  Medsy-Pharmacy
//
//  Pill badge component for labels
//

import SwiftUI

struct PillBadge: View {
    let text: String
    var foreground: Color = PharmacyColor.primary
    var background: Color = PharmacyColor.primarySoft

    var body: some View {
        Text(text)
            .font(PharmacyColor.sans(11, .semibold))
            .foregroundStyle(foreground)
            .padding(.horizontal, PharmacySpacing.xs)
            .padding(.vertical, 3)
            .background(background, in: Capsule())
    }
}
