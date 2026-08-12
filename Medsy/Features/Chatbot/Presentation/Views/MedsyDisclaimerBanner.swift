//
//  MedsyDisclaimerBanner.swift
//  Medsy
//
//  Created by ITI_JETS on 23/07/2026.
//


import SwiftUI

/// The small "Information only — not a medical diagnosis" banner.
struct MedsyDisclaimerBanner: View {
    var iconName: String = "info.circle.fill"
    var text: String

    var backgroundColor: Color = MedsyTheme.default.warningLight
    var textColor: Color = MedsyTheme.default.warning

    var body: some View {
        HStack(alignment: .top, spacing: 8) {
            Image(systemName: iconName)
                .foregroundColor(textColor)
            Text(text)
                .font(.system(size: 12))
                .foregroundColor(textColor)
        }
        .padding(12)
        .background(backgroundColor)
        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
    }
}

#Preview {
    MedsyDisclaimerBanner(
        text: "Information only — not a medical diagnosis. Always confirm with a pharmacist or doctor."
    )
    .padding()
}