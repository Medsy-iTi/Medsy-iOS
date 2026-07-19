//
//  PlaceholderDestinationView.swift
//  Medsy
//
//  Created by Shahudaa on 18/07/2026.
//

import SwiftUI

struct PlaceholderDestinationView: View {
    let titleKey: String

    var body: some View {
        VStack(spacing: PharmacySpacing.sm) {
            Image(systemName: "hammer.fill")
                .font(.system(size: 32))
                .foregroundStyle(PharmacyColor.textSecondary)
            Text(titleKey.localized)
                .font(PharmacyColor.sans(16, .semibold))
                .foregroundStyle(PharmacyColor.textPrimary)
            Text("coming_soon".localized)
                .font(PharmacyColor.sans(13))
                .foregroundStyle(PharmacyColor.textSecondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(PharmacyColor.bg)
        .navigationTitle(titleKey.localized)
        .navigationBarTitleDisplayMode(.inline)
    }
}
