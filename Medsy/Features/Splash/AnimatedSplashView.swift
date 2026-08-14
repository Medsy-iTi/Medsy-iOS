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
    @Environment(\.displayScale) private var displayScale
    @ObservedObject private var appSettings = AppSettings.shared

    @State private var logoScale: CGFloat = 0.55
    @State private var logoOpacity: Double = 0
    @State private var textOpacity: Double = 0
    @State private var textOffset: CGFloat = 40
    @State private var hasStarted = false
    @State private var hasFinished = false

    var body: some View {
        ZStack {
            splashBackground

            AndroidSplashWaves()
                .frame(height: 260)
                .frame(maxHeight: .infinity, alignment: .bottom)
                .accessibilityHidden(true)

            VStack(spacing: 0) {
                splashLogo

                VStack(spacing: 6) {
                    brandText

                    Text("splash.tagline".localized)
                        .font(.system(size: 14, weight: .regular))
                        .tracking(0.3)
                        .foregroundStyle(
                            appSettings.isDarkMode
                                ? AppColor.green
                                : AppColor.green.opacity(0.7)
                        )
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 40)
                }
                .offset(y: textOffset)
                .opacity(textOpacity)
            }
            .accessibilityElement(children: .combine)
            .accessibilityLabel("splash.accessibility_label".localized)
        }
        .preferredColorScheme(appSettings.isDarkMode ? .dark : .light)
        .onAppear(perform: startAnimations)
        .task {
            try? await Task.sleep(for: .seconds(2.8))
            guard !Task.isCancelled, !hasFinished else { return }
            hasFinished = true
            onFinished()
        }
    }

    private var splashLogo: some View {
        Image("AndroidSplashLogo")
            .resizable()
            .scaledToFit()
            .frame(width: 160, height: 160)
            .modifier(AndroidSplashShimmer(isEnabled: !reduceMotion))
            .scaleEffect(logoScale)
            .opacity(logoOpacity)
            .accessibilityHidden(true)
    }

    private var brandText: some View {
        (
            Text("splash.brand_prefix".localized)
                .foregroundStyle(AppColor.green)
            + Text("splash.brand_suffix".localized)
                .foregroundStyle(AppColor.textPrim)
        )
        .font(.system(size: 45, weight: .heavy))
        .lineLimit(1)
        .minimumScaleFactor(0.8)
        .padding(.horizontal, 16)
    }

    @ViewBuilder
    private var splashBackground: some View {
        GeometryReader { proxy in
            if appSettings.isDarkMode {
                RadialGradient(
                    colors: [
                        Color(hex: "#1D7A4D"),
                        Color(hex: "#0B1014")
                    ],
                    center: UnitPoint(
                        x: (0.5 / displayScale) / max(proxy.size.width, 1),
                        y: (0.35 / displayScale) / max(proxy.size.height, 1)
                    ),
                    startRadius: 0,
                    endRadius: 1200 / displayScale
                )
            } else {
                LinearGradient(
                    colors: [
                        Color(hex: "#E1E9E3"),
                        Color(hex: "#FFFFFF")
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                )
            }
        }
        .ignoresSafeArea()
    }

    private func startAnimations() {
        guard !hasStarted else { return }
        hasStarted = true

        let logoDuration = reduceMotion ? 0.01 : 0.9
        let textDuration = reduceMotion ? 0.01 : 0.7
        let textDelay = reduceMotion ? 0 : 0.3
        let fastOutSlowIn = Animation.timingCurve(
            0.4,
            0,
            0.2,
            1,
            duration: logoDuration
        )

        withAnimation(fastOutSlowIn) {
            logoScale = 1
        }
        withAnimation(.linear(duration: logoDuration)) {
            logoOpacity = 1
        }
        withAnimation(.linear(duration: textDuration).delay(textDelay)) {
            textOpacity = 1
        }
        withAnimation(
            .timingCurve(0.4, 0, 0.2, 1, duration: textDuration)
                .delay(textDelay)
        ) {
            textOffset = 0
        }
    }
}

private struct AndroidSplashWaves: View {
    var body: some View {
        Canvas { context, size in
            var upperWave = Path()
            upperWave.move(to: CGPoint(x: 0, y: size.height * 0.4))
            upperWave.addQuadCurve(
                to: CGPoint(x: size.width * 0.5, y: size.height * 0.4),
                control: CGPoint(x: size.width * 0.2, y: size.height * 0.2)
            )
            upperWave.addQuadCurve(
                to: CGPoint(x: size.width, y: size.height * 0.4),
                control: CGPoint(x: size.width * 0.8, y: size.height * 0.6)
            )
            upperWave.addLine(to: CGPoint(x: size.width, y: size.height))
            upperWave.addLine(to: CGPoint(x: 0, y: size.height))
            upperWave.closeSubpath()
            context.fill(upperWave, with: .color(AppColor.green.opacity(0.04)))

            var lowerWave = Path()
            lowerWave.move(to: CGPoint(x: 0, y: size.height * 0.6))
            lowerWave.addQuadCurve(
                to: CGPoint(x: size.width * 0.6, y: size.height * 0.5),
                control: CGPoint(x: size.width * 0.3, y: size.height * 0.7)
            )
            lowerWave.addQuadCurve(
                to: CGPoint(x: size.width, y: size.height * 0.6),
                control: CGPoint(x: size.width * 0.85, y: size.height * 0.35)
            )
            lowerWave.addLine(to: CGPoint(x: size.width, y: size.height))
            lowerWave.addLine(to: CGPoint(x: 0, y: size.height))
            lowerWave.closeSubpath()
            context.fill(lowerWave, with: .color(AppColor.green.opacity(0.08)))
        }
    }
}

private struct AndroidSplashShimmer: ViewModifier {
    let isEnabled: Bool
    @State private var phase: CGFloat = -1.5

    func body(content: Content) -> some View {
        if isEnabled {
            content
                .overlay {
                    GeometryReader { proxy in
                        LinearGradient(
                            colors: [.clear, .white.opacity(0.42), .clear],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                        .frame(width: proxy.size.width * 0.65)
                        .rotationEffect(.degrees(18))
                        .offset(x: phase * proxy.size.width)
                    }
                    .mask(content)
                }
                .onAppear {
                    withAnimation(.linear(duration: 0.9).repeatForever(autoreverses: false)) {
                        phase = 1.5
                    }
                }
        } else {
            content
        }
    }
}

#Preview {
    AnimatedSplashView {}
        .environment(LanguageManager.shared)
        .localizedEnvironment()
}
