//
//  PharmacyCardSurface.swift
//  Medsy-Pharmacy
//
//  Created by Ehab Salah on 14/08/2026.
//

import SwiftUI

enum PharmacyCardElevation {
    case none
    case subtle
    case raised
}

private struct PharmacyCardSurfaceModifier: ViewModifier {
    @Environment(\.colorScheme) private var colorScheme

    let cornerRadius: CGFloat
    let padding: CGFloat?
    let elevation: PharmacyCardElevation

    func body(content: Content) -> some View {
        content
            .padding(padding ?? 0)
            .background(PharmacyColor.card)
            .clipShape(cardShape)
            .overlay {
                cardShape
                    .stroke(PharmacyColor.border, lineWidth: 1)
            }
            .overlay {
                cardShape
                    .stroke(highlightColor, lineWidth: 0.5)
                    .padding(1)
            }
            .shadow(
                color: shadowColor,
                radius: shadowRadius,
                x: 0,
                y: shadowOffset
            )
    }

    private var cardShape: RoundedRectangle {
        RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
    }

    private var highlightColor: Color {
        colorScheme == .dark
            ? Color.white.opacity(0.035)
            : Color.white.opacity(0.72)
    }

    private var shadowColor: Color {
        switch elevation {
        case .none:
            return .clear
        case .subtle:
            return .black.opacity(colorScheme == .dark ? 0.24 : 0.055)
        case .raised:
            return .black.opacity(colorScheme == .dark ? 0.32 : 0.085)
        }
    }

    private var shadowRadius: CGFloat {
        switch elevation {
        case .none: 0
        case .subtle: 10
        case .raised: 18
        }
    }

    private var shadowOffset: CGFloat {
        switch elevation {
        case .none: 0
        case .subtle: 4
        case .raised: 8
        }
    }
}

private struct PharmacyInputSurfaceModifier: ViewModifier {
    let isFocused: Bool

    func body(content: Content) -> some View {
        content
            .background(
                PharmacyColor.card,
                in: RoundedRectangle(cornerRadius: PharmacyRadius.lg, style: .continuous)
            )
            .overlay {
                RoundedRectangle(cornerRadius: PharmacyRadius.lg, style: .continuous)
                    .stroke(
                        isFocused ? PharmacyColor.primary : PharmacyColor.border,
                        lineWidth: isFocused ? 1.5 : 1
                    )
            }
            .shadow(
                color: isFocused ? PharmacyColor.primary.opacity(0.1) : .clear,
                radius: 8,
                y: 3
            )
            .animation(.easeOut(duration: 0.18), value: isFocused)
    }
}

struct PharmacyIconTile: View {
    let systemImage: String
    var tint: Color = PharmacyColor.primary
    var background: Color = PharmacyColor.primarySoft
    var size: CGFloat = 40
    var iconSize: CGFloat = 16

    var body: some View {
        Image(systemName: systemImage)
            .font(.system(size: iconSize, weight: .semibold))
            .foregroundStyle(tint)
            .frame(width: size, height: size)
            .background(
                background,
                in: RoundedRectangle(cornerRadius: size * 0.3, style: .continuous)
            )
            .accessibilityHidden(true)
    }
}

struct PharmacySectionHeader: View {
    let title: String
    var subtitle: String?
    var systemImage: String?

    var body: some View {
        HStack(alignment: .center, spacing: PharmacySpacing.sm) {
            if let systemImage {
                PharmacyIconTile(systemImage: systemImage, size: 36, iconSize: 15)
            }

            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(PharmacyColor.sans(17, .bold))
                    .foregroundStyle(PharmacyColor.textPrimary)

                if let subtitle, !subtitle.isEmpty {
                    Text(subtitle)
                        .font(PharmacyColor.sans(12))
                        .foregroundStyle(PharmacyColor.textSecondary)
                }
            }

            Spacer(minLength: 0)
        }
    }
}

struct PharmacyPressableButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.98 : 1)
            .opacity(configuration.isPressed ? 0.88 : 1)
            .animation(.easeOut(duration: 0.14), value: configuration.isPressed)
    }
}

extension View {
    func pharmacyCard(
        cornerRadius: CGFloat = PharmacyRadius.lg,
        padding: CGFloat? = PharmacySpacing.md,
        elevation: PharmacyCardElevation = .subtle
    ) -> some View {
        modifier(
            PharmacyCardSurfaceModifier(
                cornerRadius: cornerRadius,
                padding: padding,
                elevation: elevation
            )
        )
    }

    func pharmacyInputSurface(isFocused: Bool = false) -> some View {
        modifier(PharmacyInputSurfaceModifier(isFocused: isFocused))
    }

}

#if DEBUG
struct PharmacyPreviewHost<Content: View>: View {
    @ObservedObject private var appSettings = PharmacyAppSettings.shared
    private let languageManager = LanguageManager.shared

    let isDarkMode: Bool
    let language: PharmacyAppLanguage
    @ViewBuilder let content: Content

    var body: some View {
        content
            .environment(languageManager)
            .pharmacyLocalizedEnvironment()
            .preferredColorScheme(isDarkMode ? .dark : .light)
            .onAppear {
                appSettings.themePreference = isDarkMode ? .dark : .light
                languageManager.set(language)
            }
    }
}

#Preview("Cards · Light · English") {
    PharmacyPreviewHost(isDarkMode: false, language: .english) {
        VStack(alignment: .leading, spacing: PharmacySpacing.md) {
            PharmacySectionHeader(
                title: "Order overview",
                subtitle: "Updated a few moments ago",
                systemImage: "shippingbox.fill"
            )

            HStack(spacing: PharmacySpacing.sm) {
                PharmacyIconTile(systemImage: "pills.fill")
                VStack(alignment: .leading, spacing: 3) {
                    Text("Requested medicines")
                        .font(PharmacyColor.sans(16, .bold))
                        .foregroundStyle(PharmacyColor.textPrimary)
                    Text("Three products are ready to review")
                        .font(PharmacyColor.sans(13))
                        .foregroundStyle(PharmacyColor.textSecondary)
                }
            }
            .pharmacyCard(elevation: .raised)

            PharmacyPrimaryButton(title: "Continue", systemImage: "arrow.forward") {}
        }
        .padding(PharmacySpacing.md)
        .background(PharmacyColor.bg)
    }
}

#Preview("Cards · Dark · Arabic") {
    PharmacyPreviewHost(isDarkMode: true, language: .arabic) {
        VStack(alignment: .leading, spacing: PharmacySpacing.md) {
            PharmacySectionHeader(
                title: "نظرة عامة على الطلب",
                subtitle: "تم التحديث منذ لحظات",
                systemImage: "shippingbox.fill"
            )

            HStack(spacing: PharmacySpacing.sm) {
                PharmacyIconTile(systemImage: "pills.fill")
                VStack(alignment: .leading, spacing: 3) {
                    Text("الأدوية المطلوبة")
                        .font(PharmacyColor.sans(16, .bold))
                        .foregroundStyle(PharmacyColor.textPrimary)
                    Text("ثلاثة منتجات جاهزة للمراجعة")
                        .font(PharmacyColor.sans(13))
                        .foregroundStyle(PharmacyColor.textSecondary)
                }
            }
            .pharmacyCard(elevation: .raised)

            PharmacyPrimaryButton(title: "متابعة", systemImage: "arrow.forward") {}
        }
        .padding(PharmacySpacing.md)
        .background(PharmacyColor.bg)
    }
}
#endif
