//
//  OnboardingPageView.swift
//  Medsy-Pharmacy
//
//

import SwiftUI

struct OnboardingPageView: View {
    let page: OnboardingPage

    let isActive: Bool

    @State private var imageScale: CGFloat = 0.85
    @State private var imageOpacity: Double = 0
    @State private var textOpacity: Double = 0

    var body: some View {
        VStack(spacing: PharmacySpacing.xl) {
            Spacer(minLength: PharmacySpacing.md)

            Image(page.imageName)
                .resizable()
                .scaledToFit()
                .frame(maxHeight: 320)
                .scaleEffect(imageScale)
                .opacity(imageOpacity)

            VStack(spacing: PharmacySpacing.sm) {
                Text(page.titleKey.localized)
                    .font(PharmacyColor.sans(22, .bold))
                    .foregroundStyle(PharmacyColor.textPrimary)
                    .multilineTextAlignment(.center)

                Text(page.subtitleKey.localized)
                    .font(PharmacyColor.sans(15))
                    .foregroundStyle(PharmacyColor.textSecondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, PharmacySpacing.lg)
            }
            .padding(.vertical, PharmacySpacing.md)
            .frame(maxWidth: 420)
            .pharmacyCard(
                cornerRadius: PharmacyRadius.xl,
                padding: nil,
                elevation: .subtle
            )
            .padding(.horizontal, PharmacySpacing.lg)
            .opacity(textOpacity)

            Spacer(minLength: PharmacySpacing.md)
        }
        .onAppear { animateIn() }
        .onChange(of: isActive) { _, active in
            if active { animateIn() }
        }
    }

    private func animateIn() {
        imageScale = 0.85
        imageOpacity = 0
        textOpacity = 0
        withAnimation(.spring(response: 0.55, dampingFraction: 0.75)) {
            imageScale = 1
            imageOpacity = 1
        }
        withAnimation(.easeOut(duration: 0.4).delay(0.15)) {
            textOpacity = 1
        }
    }
}
