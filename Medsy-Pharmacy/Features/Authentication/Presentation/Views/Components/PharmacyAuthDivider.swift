//  PharmacyAuthDivider.swift
//  Medsy
//
//  Created by Antoneos Philip on 17/07/2026.

import SwiftUI

struct PharmacyAuthDivider: View {
    var body: some View {
        HStack(spacing: 12) {
            Rectangle().fill(PharmacyColor.border).frame(height: 1)
            Text("auth.or".localized)
                .font(.footnote.weight(.medium))
                .foregroundStyle(PharmacyColor.textSecondary)
            Rectangle().fill(PharmacyColor.border).frame(height: 1)
        }
    }
}
