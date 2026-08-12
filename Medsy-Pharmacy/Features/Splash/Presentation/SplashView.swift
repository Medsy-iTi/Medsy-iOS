//
//  SplashView.swift
//  Medsy-Pharmacy
//
//

import SwiftUI

struct SplashView: View {
    let onFinished: () -> Void

    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @ObservedObject private var appSettings = PharmacyAppSettings.shared

    @State private var logoScale: CGFloat = 0.68
    @State private var logoRotation: Double = -8
    @State private var logoOpacity: Double = 0
    @State private var contentOffset: CGFloat = 22
    @State private var contentOpacity: Double = 0
    @State private var waveOffset: CGFloat = 54
    @State private var waveDrift: CGFloat = -10
    @State private var isPulsing = false
    @State private var hasStarted = false
    @State private var hasFinished = false

    var body: some View {
        ZStack {
            LinearGradient(
                colors: [PharmacyColor.bg, PharmacyColor.surface],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()

            ambientGlow

            WaveShape(amplitude: 30, verticalOffset: 0.78)
                .fill(PharmacyColor.primarySoft)
                .scaleEffect(x: 1.08, y: 1, anchor: .center)
                .offset(x: waveDrift, y: waveOffset)
                .ignoresSafeArea()
                .accessibilityHidden(true)

            WaveShape(amplitude: 22, verticalOffset: 0.86)
                .fill(PharmacyColor.primary.opacity(appSettings.isDarkMode ? 0.2 : 0.12))
                .scaleEffect(x: 1.08, y: 1, anchor: .center)
                .offset(x: -waveDrift, y: waveOffset * 0.6)
                .ignoresSafeArea()
                .accessibilityHidden(true)

            VStack(spacing: PharmacySpacing.lg) {
                Spacer()

                VStack(spacing: PharmacySpacing.sm) {
                    ZStack {
                        Circle()
                            .fill(PharmacyColor.primarySoft)
                            .frame(width: 210, height: 210)
                            .scaleEffect(isPulsing ? 1.08 : 0.94)
                            .opacity(isPulsing ? 0.45 : 0.85)

                        Image(.splashP2)
                            .resizable()
                            .scaledToFit()
                            .frame(width: 210, height: 210)
                    }
                    .scaleEffect(logoScale * (isPulsing ? 1.02 : 1))
                    .rotationEffect(.degrees(logoRotation))
                    .opacity(logoOpacity)
                    .shadow(
                        color: PharmacyColor.primary.opacity(appSettings.isDarkMode ? 0.32 : 0.18),
                        radius: 26,
                        y: 12
                    )
                    .accessibilityHidden(true)

                    VStack(spacing: PharmacySpacing.xs) {
                        Text("pharmacy.splash.brand".localized)
                            .font(PharmacyColor.sans(34, .bold))
                            .foregroundStyle(PharmacyColor.primary)

                        Text("pharmacy.splash.subtitle".localized)
                            .font(PharmacyColor.sans(16, .semibold))
                            .foregroundStyle(PharmacyColor.textPrimary)

                        Text("pharmacy.splash.tagline".localized)
                            .font(PharmacyColor.sans(14))
                            .foregroundStyle(PharmacyColor.textSecondary)
                            .multilineTextAlignment(.center)
                            .lineSpacing(3)
                            .padding(.horizontal, PharmacySpacing.xl)
                    }
                    .offset(y: contentOffset)
                    .opacity(contentOpacity)
                }
                .accessibilityElement(children: .combine)
                .accessibilityLabel("pharmacy.splash.accessibility_label".localized)

                Spacer()
                Spacer()
            }
        }
        .preferredColorScheme(appSettings.isDarkMode ? .dark : .light)
        .onAppear(perform: startAnimations)
        .task {
            try? await Task.sleep(for: .seconds(reduceMotion ? 1.5 : 2.8))
            guard !Task.isCancelled, !hasFinished else { return }
            hasFinished = true
            withAnimation(.easeOut(duration: reduceMotion ? 0.01 : 0.25)) {
                onFinished()
            }
        }
    }

    private var ambientGlow: some View {
        Circle()
            .fill(PharmacyColor.primary.opacity(appSettings.isDarkMode ? 0.16 : 0.08))
            .frame(width: 320, height: 320)
            .blur(radius: 24)
            .scaleEffect(isPulsing ? 1.12 : 0.9)
            .offset(y: -120)
            .accessibilityHidden(true)
    }

    private func startAnimations() {
        guard !hasStarted else { return }
        hasStarted = true

        withAnimation(.spring(response: reduceMotion ? 0.01 : 0.7, dampingFraction: 0.72)) {
            logoScale = 1
            logoRotation = 0
            logoOpacity = 1
        }

        withAnimation(.easeOut(duration: reduceMotion ? 0.01 : 0.6).delay(reduceMotion ? 0 : 0.2)) {
            contentOffset = 0
            contentOpacity = 1
        }

        withAnimation(.easeOut(duration: reduceMotion ? 0.01 : 1.1)) {
            waveOffset = 0
        }

        guard !reduceMotion else { return }

        withAnimation(.easeInOut(duration: 1.35).repeatForever(autoreverses: true)) {
            isPulsing = true
            waveDrift = 10
        }
    }
}

#Preview {
    SplashView {}
        .environment(LanguageManager.shared)
        .pharmacyLocalizedEnvironment()
}
