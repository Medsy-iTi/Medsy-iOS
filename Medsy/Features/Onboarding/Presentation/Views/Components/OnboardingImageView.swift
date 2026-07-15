//
//  OnboardingIllustrationView.swift
//  Medsy
//
//  Created by Ehab Salah on 15/07/2026.
//

import SwiftUI

struct OnboardingImageView: View {
    let imageName: String

    var body: some View {
        ZStack {
            Circle()
                .fill(AppColor.green.opacity(0.08))
                .padding(18)

            Image(imageName)
                .resizable()
                .scaledToFit()
                .padding(6)
                .accessibilityHidden(true)
        }
        .aspectRatio(1, contentMode: .fit)
    }
}

#Preview {
    OnboardingImageView(imageName: "OnboardingOrder")
        .frame(width: 320)
        .padding()
}
