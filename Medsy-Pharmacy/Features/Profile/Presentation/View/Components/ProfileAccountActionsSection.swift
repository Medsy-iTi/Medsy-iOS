//
//  ProfileAccountActionsSection.swift
//  Medsy-Pharmacy
//

import SwiftUI

struct ProfileAccountActionsSection: View {
    let onLogout: () -> Void

    var body: some View {
        ProfileSectionContainer {
            ProfileNavigationRow(
                icon: "rectangle.portrait.and.arrow.right",
                iconTint: PharmacyColor.danger,
                title: "logout_title".localized,
                action: onLogout
            )
        }
    }
}
