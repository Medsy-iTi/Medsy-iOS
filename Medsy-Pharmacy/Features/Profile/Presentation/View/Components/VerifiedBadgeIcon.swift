//
//  VerifiedBadgeIcon.swift
//  Medsy-Pharmacy
//
//  Verified badge icon component
//

import SwiftUI

/// Small blue checkmark used next to verified names, matching the design mock.
struct VerifiedBadgeIcon: View {
    var size: CGFloat = 16

    var body: some View {
        Image(systemName: "checkmark.seal.fill")
            .resizable()
            .scaledToFit()
            .frame(width: size, height: size)
            .foregroundStyle(PharmacyColor.primary)
    }
}
