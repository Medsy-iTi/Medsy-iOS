//
//  ProfileAccountActionsSection.swift
//  Medsy-Pharmacy
//

import SwiftUI

struct ProfileAccountActionsSection: View {
    let onEditProfile: () -> Void
    let onLogout: () -> Void

    var body: some View {
        ProfileSectionContainer {
            ProfileNavigationRow(
                icon: "pencil",
                title: "profile.edit.title".localized,
                action: onEditProfile
            )

            ProfileRowDivider()

            ProfileNavigationRow(
                icon: "rectangle.portrait.and.arrow.right",
                iconTint: PharmacyColor.danger,
                title: "logout_title".localized,
                action: onLogout
            )
        }
    }
}
