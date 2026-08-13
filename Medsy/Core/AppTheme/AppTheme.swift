//
//  AppTheme.swift
//  Medsy
//
//  Created by Antoneos Philip on 14/07/2026.
//

import Foundation
import SwiftUI

class AppSettings: ObservableObject {
    static let shared = AppSettings()

    private enum Keys {
        static let isDarkMode = "app_is_dark_mode"
    }

    @Published var isDarkMode: Bool {
        didSet {
            UserDefaults.standard.set(isDarkMode, forKey: Keys.isDarkMode)
        }
    }

    private init() {
        isDarkMode = UserDefaults.standard.bool(forKey: Keys.isDarkMode)
    }
}

enum AppColor {
    private static var isDarkMode: Bool { AppSettings.shared.isDarkMode }

    // MARK: - Android Material color scheme

    static let green = Color(hex: "#048C4E")
    static let white = Color(hex: "#FFFFFF")

    static var primaryContainer: Color {
        isDarkMode ? Color(hex: "#1D7A4D") : Color(hex: "#D6F5E2")
    }
    static var onPrimaryContainer: Color {
        isDarkMode ? Color(hex: "#E6FFEE") : Color(hex: "#00210F")
    }
    static var secondary: Color {
        isDarkMode ? Color(hex: "#B6CCB9") : Color(hex: "#4E6355")
    }
    static var secondaryContainer: Color {
        isDarkMode ? Color(hex: "#384B3C") : Color(hex: "#D2E8D8")
    }
    static var onSecondaryContainer: Color {
        isDarkMode ? Color(hex: "#D2E8D4") : Color(hex: "#0C1F15")
    }
    static var tertiary: Color {
        isDarkMode ? Color(hex: "#A2CEDA") : Color(hex: "#356571")
    }
    static var tertiaryContainer: Color {
        isDarkMode ? Color(hex: "#214C57") : Color(hex: "#BCEAF5")
    }

    static var background: Color {
        isDarkMode ? Color(hex: "#0B1014") : Color(hex: "#F7F9F8")
    }
    static var onBackground: Color {
        isDarkMode ? Color(hex: "#E1E6E3") : Color(hex: "#181C19")
    }
    static var surface: Color {
        isDarkMode ? Color(hex: "#0E1418") : Color(hex: "#FFFFFF")
    }
    static var onSurface: Color {
        isDarkMode ? Color(hex: "#E1E6E3") : Color(hex: "#181C19")
    }
    static var surfaceVariant: Color {
        isDarkMode ? Color(hex: "#28332F") : Color(hex: "#E1E9E3")
    }
    static var onSurfaceVariant: Color {
        isDarkMode ? Color(hex: "#BEC9C2") : Color(hex: "#414943")
    }
    static var surfaceContainerLowest: Color {
        isDarkMode ? Color(hex: "#070B0E") : Color(hex: "#FFFFFF")
    }
    static var surfaceContainerLow: Color {
        isDarkMode ? Color(hex: "#10161A") : Color(hex: "#F3F6F4")
    }
    static var surfaceContainer: Color {
        isDarkMode ? Color(hex: "#141B1F") : Color(hex: "#EDF1EE")
    }
    static var surfaceContainerHigh: Color {
        isDarkMode ? Color(hex: "#192126") : Color(hex: "#E7EBE8")
    }
    static var surfaceContainerHighest: Color {
        isDarkMode ? Color(hex: "#202A2F") : Color(hex: "#E1E6E2")
    }
    static var outline: Color {
        isDarkMode ? Color(hex: "#89938D") : Color(hex: "#717A73")
    }
    static var outlineVariant: Color {
        isDarkMode ? Color(hex: "#3C4741") : Color(hex: "#C0C9C2")
    }

    // MARK: - Android extended colors

    static var success: Color {
        isDarkMode ? Color(hex: "#78E29A") : Color(hex: "#166534")
    }
    static var successContainer: Color {
        isDarkMode ? Color(hex: "#0F4D2D") : Color(hex: "#DCFCE7")
    }
    static var warning: Color {
        isDarkMode ? Color(hex: "#FFB86C") : Color(hex: "#9A5800")
    }
    static var warningContainer: Color {
        isDarkMode ? Color(hex: "#5D3A0A") : Color(hex: "#FFEDD5")
    }
    static var error: Color {
        isDarkMode ? Color(hex: "#FFB4AB") : Color(hex: "#BA1A1A")
    }
    static var errorContainer: Color {
        isDarkMode ? Color(hex: "#93000A") : Color(hex: "#FFDAD6")
    }
    static var info: Color {
        isDarkMode ? Color(hex: "#AFC6FF") : Color(hex: "#1D4ED8")
    }
    static var infoContainer: Color {
        isDarkMode ? Color(hex: "#163E86") : Color(hex: "#DBEAFE")
    }

    static var categoryContainer: Color {
        isDarkMode ? Color(hex: "#1D7A4D") : Color(hex: "#E6FFEE")
    }
    static var onCategoryContainer: Color {
        isDarkMode ? Color(hex: "#E6FFEE") : green
    }
    static let blueContainer = Color(hex: "#E0E7FF")
    static let blueContent = Color(hex: "#3B82F6")
    static let orangeContainer = Color(hex: "#FFEDD5")
    static let orangeContent = Color(hex: "#F97316")
    static let pinkContainer = Color(hex: "#FCE7F3")
    static let pinkContent = Color(hex: "#EC4899")
    static let purpleContainer = Color(hex: "#F3E8FF")
    static let purpleContent = Color(hex: "#8B5CF6")
    static let neutralContainer = Color(hex: "#F3F4F6")
    static let neutralContent = Color(hex: "#6B7280")

    // MARK: - Existing semantic aliases

    static var bg: Color { background }
    static var card: Color { surface }
    static var border: Color { outlineVariant }
    static var darkGreen: Color { green }
    static var lightGreen: Color { primaryContainer }
    static var textPrim: Color { onSurface }
    static var textSec: Color { onSurfaceVariant }
    static var hintPlaceholder: Color { outline }
    static var btnBg: Color { green }
    static var btnText: Color { white }
    static var tagNew: Color { green }
    static var tagSold: Color { error }
    static var successGreen: Color { success }
    static var errorRed: Color { error }
    static var warningYellow: Color { warning }
    static let badgePurple = Color(hex: "#6366F1")
    static var pill: Color { primaryContainer }
    static var pillSel: Color { green }
    static var warningBg: Color { warningContainer }
    static var warningBorder: Color { warning }

    static func serif(_ size: CGFloat, _ weight: Font.Weight = .regular) -> Font {
        Font.system(size: size, weight: weight, design: .serif)
    }

    static func sans(_ size: CGFloat, _ weight: Font.Weight = .regular) -> Font {
        Font.system(size: size, weight: weight)
    }


	static var danger: Color { error }
    static var dangerLight: Color { errorContainer }
    static var warningLight: Color { warningContainer }

	static var skeleton: Color { surfaceContainerHigh }

}

extension Color {
    init(hex: String) {
        let h = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var val: UInt64 = 0
        Scanner(string: h).scanHexInt64(&val)
        let r = Double((val >> 16) & 0xFF) / 255
        let g = Double((val >> 8) & 0xFF) / 255
        let b = Double(val & 0xFF) / 255
        self.init(red: r, green: g, blue: b)
    }
}

// MARK: - MedsyTheme

/// Central colour palette consumed by Medsy chatbot components.
/// Uses `AppColor` as the single source of truth so dark-mode aware
/// colours stay reactive — no duplicate hex literals.
struct MedsyTheme {
    var primary:      Color
    var primaryLight: Color
    var danger:       Color
    var dangerLight:  Color
    var warning:      Color
    var warningLight: Color
    var surface:      Color
    var textPrimary:  Color
    var textSecondary: Color

    /// Default Medsy palette — delegates to `AppColor` wherever possible.
    static var `default`: MedsyTheme { MedsyTheme(
        primary:       AppColor.green,
        primaryLight:  AppColor.lightGreen,
        danger:        AppColor.errorRed,
        dangerLight:   AppColor.dangerLight,
        warning:       AppColor.warningYellow,       // #F59E0B
        warningLight:  AppColor.warningLight,
        surface:       AppColor.surface,
        textPrimary:   AppColor.textPrim,
        textSecondary: AppColor.textSec
    ) }
}


enum MedsySpacing {
	static let xxs: CGFloat = 4
	static let xs: CGFloat = 8
	static let sm: CGFloat = 12
	static let md: CGFloat = 16
	static let lg: CGFloat = 20
	static let xl: CGFloat = 28
	static let xxl: CGFloat = 40
}

	// MARK: - Radius

enum MedsyRadius {
	static let sm: CGFloat = 8
	static let md: CGFloat = 12
	static let lg: CGFloat = 16
	static let pill: CGFloat = 999
}

	// MARK: - Typography


enum MedsyFont {
	static func title(_ size: CGFloat = 18) -> Font {
		.system(size: size, weight: .bold)
	}
	static func body(_ size: CGFloat = 15) -> Font {
		.system(size: size, weight: .regular)
	}
	static func bodyMedium(_ size: CGFloat = 15) -> Font {
		.system(size: size, weight: .medium)
	}
	static func caption(_ size: CGFloat = 13) -> Font {
		.system(size: size, weight: .regular)
	}
	static func price(_ size: CGFloat = 15) -> Font {
		.system(size: size, weight: .bold)
	}
	static func button(_ size: CGFloat = 16) -> Font {
		.system(size: size, weight: .semibold)
	}
}

	// MARK: - Shadow

extension View {

	func medsyCardShadow() -> some View {
		self.shadow(color: Color.black.opacity(0.06), radius: 8, x: 0, y: 2)
	}
}
