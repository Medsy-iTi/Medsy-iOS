//
//  ProfilePresenceSection.swift
//  Medsy-Pharmacy
//

import SwiftUI

struct ProfilePresenceSection: View {
    let isOnDuty: Bool
    let isLoading: Bool
    let errorMessage: String?
    let onToggle: () -> Void

    // Local binding to trigger the view model intent
    private var toggleBinding: Binding<Bool> {
        Binding(
            get: { isOnDuty },
            set: { _ in onToggle() }
        )
    }

    var body: some View {
        VStack(alignment: .leading, spacing: PharmacySpacing.sm) {
            PharmacySectionHeader(
                title: "profile.presence.section_title".localized,
                systemImage: "clock.badge.checkmark"
            )

            ProfileSectionContainer {
                ProfileToggleRow(
                    icon: "clock.badge.checkmark",
                    title: "profile.presence.on_duty_title".localized,
                    badgeText: isOnDuty ? "profile.presence.on_duty_badge".localized : "profile.presence.off_duty_badge".localized,
                    isLoading: isLoading,
                    isOn: toggleBinding
                )
            }

            if let errorMessage = errorMessage {
                Text(errorMessage)
                    .font(PharmacyColor.sans(12, .medium))
                    .foregroundStyle(PharmacyColor.danger)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, 4)
            }
        }
    }
}
