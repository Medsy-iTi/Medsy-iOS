//
//  PharmacyAppTheme.swift
//  Medsy-Pharmacy
//
//  Created by Ahmed Elkady on 17/07/2026.
//

import SwiftUI

final class PharmacyAppSettings: ObservableObject {
    static let shared = PharmacyAppSettings()

    private enum Keys {
        static let isDarkMode = "pharmacy_is_dark_mode"
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

enum PharmacyColor {
    private static func dynamic(light: String, dark: String) -> Color {
        Color(UIColor { trait in
            trait.userInterfaceStyle == .dark ? UIColor(Color(hex: dark)) : UIColor(Color(hex: light))
        })
    }

    static var bg: Color { dynamic(light: "#F7FAFF", dark: "#07111F") }
    static var surface: Color { dynamic(light: "#FFFFFF", dark: "#0B1728") }
    static var card: Color { dynamic(light: "#FFFFFF", dark: "#101D31") }
    static var border: Color { dynamic(light: "#DDE8F6", dark: "#20324F") }
    static var primary: Color { Color(hex: "#0B63E5") }
    static var primaryDark: Color { Color(hex: "#103F8F") }
    static var secondary: Color { Color(hex: "#7956D8") }
    static var primarySoft: Color { dynamic(light: "#EAF3FF", dark: "#102A52") }
    static var secondarySoft: Color { dynamic(light: "#F0ECFF", dark: "#24204D") }
    static var successSoft: Color { dynamic(light: "#E8F8F0", dark: "#123D36") }
    static var warningSoft: Color { dynamic(light: "#FFF1E5", dark: "#4A3015") }
    static var mutedSurface: Color { dynamic(light: "#F3F7FD", dark: "#132238") }
    static var textPrimary: Color { dynamic(light: "#071833", dark: "#F8FBFF") }
    static var textSecondary: Color { dynamic(light: "#5C6D86", dark: "#9DAEC8") }
    static var success: Color { Color(hex: "#12B76A") }
    static var warning: Color { Color(hex: "#F59E0B") }
    static var danger: Color { Color(hex: "#E5484D") }

    static func sans(_ size: CGFloat, _ weight: Font.Weight = .regular) -> Font {
        .system(size: size, weight: weight)
    }
}

enum PharmacySpacing {
    static let xxs: CGFloat = 4
    static let xs: CGFloat = 8
    static let sm: CGFloat = 12
    static let md: CGFloat = 16
    static let lg: CGFloat = 20
    static let xl: CGFloat = 28
}

enum PharmacyRadius {
    static let sm: CGFloat = 8
    static let md: CGFloat = 12
    static let lg: CGFloat = 16
    static let xl: CGFloat = 22
    static let pill: CGFloat = 999
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
