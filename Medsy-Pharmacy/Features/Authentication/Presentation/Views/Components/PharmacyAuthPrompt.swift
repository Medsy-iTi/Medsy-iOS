//  PharmacyAuthPrompt.swift
//  Medsy
//
//  Created by Antoneos Philip on 17/07/2026.

import SwiftUI

struct PharmacyAuthPrompt: View {
    let leadingText: String
    let actionTitle: String

    var body: some View {
        HStack(spacing: 4) {
            Text(leadingText)
                .foregroundStyle(PharmacyColor.textSecondary)
            Button(actionTitle,action: {})
                .fontWeight(.semibold)
                .foregroundStyle(PharmacyColor.primary)
        }
        .font(.footnote)
        .frame(maxWidth: .infinity)
    }
}
