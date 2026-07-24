//
//  PharmacyBadgeView.swift
//  Medsy
//
//  Created by Shahudaa on 18/07/2026.
//

import SwiftUI


struct PharmacyBadgeView: View {
    let systemImage: String
    let tint: Color

    var body: some View {
        Image(systemName: systemImage)
            .font(.system(size: 13, weight: .bold))
            .foregroundStyle(tint)
            .accessibilityHidden(true)
    }
}
