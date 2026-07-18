//
//  SplashView.swift
//  Medsy-Pharmacy
//
//

import SwiftUI

struct SplashView: View {
    let onFinished: () -> Void

    @State private var logoScale: CGFloat = 0.6
    @State private var logoOpacity: Double = 0
    @State private var textOffset: CGFloat = 16
    @State private var textOpacity: Double = 0
    @State private var waveOffset: CGFloat = 40
    @State private var hasFinished = false

    var body: some View {
        ZStack {
            PharmacyColor.bg
                .ignoresSafeArea()

            WaveShape(amplitude: 30, verticalOffset: 0.78)
                .fill(PharmacyColor.primarySoft)
                .offset(y: waveOffset)
                .ignoresSafeArea()

            WaveShape(amplitude: 22, verticalOffset: 0.86)
                .fill(PharmacyColor.primary.opacity(0.12))
                .offset(y: waveOffset * 0.6)
                .ignoresSafeArea()

            VStack(spacing: PharmacySpacing.lg) {
                Spacer()

                VStack(spacing: PharmacySpacing.xs) {
					Image(.splashP2)
						.resizable()
						.frame(width: 250, height: 250)
						.scaleEffect(logoScale)
						.opacity(logoOpacity)
                    Text("Medsy")
                        .font(PharmacyColor.sans(34, .bold))
                        .foregroundStyle(PharmacyColor.primary)

                    Text("pharmacy.splash.subtitle".localized)
                        .font(PharmacyColor.sans(16, .semibold))
                        .foregroundStyle(PharmacyColor.textPrimary)

                    Text("pharmacy.splash.tagline".localized)
                        .font(PharmacyColor.sans(14))
                        .foregroundStyle(PharmacyColor.textSecondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, PharmacySpacing.xl)
                }
                .offset(y: textOffset)
                .opacity(textOpacity)

                Spacer()
                Spacer()
            }
        }
        .onAppear {
            withAnimation(.spring(response: 0.55, dampingFraction: 0.7)) {
                logoScale = 1
                logoOpacity = 1
            }
            withAnimation(.easeOut(duration: 0.5).delay(0.2)) {
                textOffset = 0
                textOpacity = 1
            }
            withAnimation(.easeOut(duration: 1.1)) {
                waveOffset = 0
            }
            
            Task { @MainActor in
                try? await Task.sleep(for: .seconds(2.2))
                guard !hasFinished else { return }
                hasFinished = true
                withAnimation(.easeOut(duration: 0.22)) {
                    onFinished()
                }
            }
        }
    }
}

#Preview {
    SplashView {}
}
