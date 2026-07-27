//
//  AnimatedSplashView.swift
//  Medsy
//
//  Created by Ehab Salah on 15/07/2026.
//

import SwiftUI

struct AnimatedSplashView: View {
    let onFinished: () -> Void

    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @ObservedObject private var appSettings = AppSettings.shared

    @State private var logoScale: CGFloat = 0.72
    @State private var logoRotation: Double = -7
    @State private var logoOpacity: Double = 0
    @State private var textOffset: CGFloat = 20
    @State private var textOpacity: Double = 0
    @State private var ringProgress: CGFloat = 0
    @State private var ringRotation: Double = -35
    @State private var isBreathing = false
    @State private var hasStarted = false
    @State private var hasFinished = false

    var body: some View {
        ZStack {
            LinearGradient(
                colors: [AppColor.bg, AppColor.surface],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            ambientBackground

            VStack(spacing: MedsySpacing.lg) {
                Spacer()

                ZStack {
                    Circle()
                        .fill(AppColor.pill)
                        .frame(width: 250, height: 250)
                        .scaleEffect(isBreathing ? 1.07 : 0.94)
                        .opacity(isBreathing ? 0.58 : 0.9)

                    Circle()
                        .trim(from: 0, to: ringProgress * 0.82)
                        .stroke(
                            AngularGradient(
                                colors: [
                                    AppColor.green.opacity(0.08),
                                    AppColor.green,
                                    AppColor.green.opacity(0.08)
                                ],
                                center: .center
                            ),
                            style: StrokeStyle(lineWidth: 3, lineCap: .round)
                        )
                        .frame(width: 236, height: 236)
                        .rotationEffect(.degrees(ringRotation))

                    Image("SplashLogo")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 205, height: 205)
                }
                .scaleEffect(logoScale * (isBreathing ? 1.015 : 1))
                .rotationEffect(.degrees(logoRotation))
                .opacity(logoOpacity)
                .shadow(
                    color: AppColor.green.opacity(appSettings.isDarkMode ? 0.3 : 0.17),
                    radius: 26,
                    y: 12
                )
                .accessibilityHidden(true)

                VStack(spacing: MedsySpacing.xs) {
                    Text("splash.brand".localized)
                        .font(AppColor.sans(36, .bold))
                        .foregroundStyle(AppColor.green)

                    Text("splash.tagline".localized)
                        .font(AppColor.sans(17, .semibold))
                        .foregroundStyle(AppColor.textPrim)

                    Text("splash.subtitle".localized)
                        .font(AppColor.sans(14))
                        .foregroundStyle(AppColor.hintPlaceholder)
                        .multilineTextAlignment(.center)
                        .lineSpacing(3)
                        .padding(.horizontal, MedsySpacing.xl)
                }
                .offset(y: textOffset)
                .opacity(textOpacity)
                .accessibilityElement(children: .combine)
                .accessibilityLabel("splash.accessibility_label".localized)

                Spacer()
                Spacer()
            }
        }
        .preferredColorScheme(appSettings.isDarkMode ? .dark : .light)
        .onAppear(perform: startAnimations)
        .task {
            try? await Task.sleep(for: .seconds(reduceMotion ? 1.5 : 2.7))
            guard !Task.isCancelled, !hasFinished else { return }
            hasFinished = true

            withAnimation(.easeOut(duration: reduceMotion ? 0.01 : 0.25)) {
                onFinished()
            }
        }
    }

    private var ambientBackground: some View {
        ZStack {
            Circle()
                .fill(AppColor.green.opacity(appSettings.isDarkMode ? 0.15 : 0.08))
                .frame(width: 340, height: 340)
                .blur(radius: 30)
                .scaleEffect(isBreathing ? 1.12 : 0.9)
                .offset(x: -150, y: -260)

            Circle()
                .fill(AppColor.green.opacity(appSettings.isDarkMode ? 0.1 : 0.05))
                .frame(width: 270, height: 270)
                .blur(radius: 26)
                .scaleEffect(isBreathing ? 0.92 : 1.08)
                .offset(x: 170, y: 290)
        }
        .accessibilityHidden(true)
    }

    private func startAnimations() {
        guard !hasStarted else { return }
        hasStarted = true

        withAnimation(.spring(response: reduceMotion ? 0.01 : 0.72, dampingFraction: 0.74)) {
            logoScale = 1
            logoRotation = 0
            logoOpacity = 1
        }

        withAnimation(.easeOut(duration: reduceMotion ? 0.01 : 0.65).delay(reduceMotion ? 0 : 0.2)) {
            textOffset = 0
            textOpacity = 1
        }

        withAnimation(.easeOut(duration: reduceMotion ? 0.01 : 1)) {
            ringProgress = 1
        }

        guard !reduceMotion else { return }

        withAnimation(.linear(duration: 4).repeatForever(autoreverses: false)) {
            ringRotation = 325
        }

        withAnimation(.easeInOut(duration: 1.45).repeatForever(autoreverses: true)) {
            isBreathing = true
        }
    }
}

#Preview {
    AnimatedSplashView {}
        .environment(LanguageManager.shared)
        .localizedEnvironment()
}
