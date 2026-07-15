//
//  OnboardingHeader.swift
//  Medsy
//
//  Created by Ehab Salah on 15/07/2026.
//

import SwiftUI

struct OnboardingHeader: View {
    let onSkip: () -> Void

    var body: some View {
        HStack {
            Spacer()

            Button("onboarding.skip".localized, action: onSkip)
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(.secondary)
                .buttonStyle(.plain)
                .contentShape(Rectangle())
                .padding(.vertical, 10)
        }
    }
}

#Preview {
    OnboardingHeader {}
        .padding(.horizontal)
}
