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
    static var bg: Color { PharmacyAppSettings.shared.isDarkMode ? Color(hex: "#07111F") : Color(hex: "#F7FAFF") }
    static var surface: Color { PharmacyAppSettings.shared.isDarkMode ? Color(hex: "#0B1728") : Color(hex: "#FFFFFF") }
    static var card: Color { PharmacyAppSettings.shared.isDarkMode ? Color(hex: "#101D31") : Color(hex: "#FFFFFF") }
    static var border: Color { PharmacyAppSettings.shared.isDarkMode ? Color(hex: "#20324F") : Color(hex: "#DDE8F6") }
    static var primary: Color { Color(hex: "#0B63E5") }
    static var primaryDark: Color { Color(hex: "#103F8F") }
    static var secondary: Color { Color(hex: "#7956D8") }
    static var primarySoft: Color { PharmacyAppSettings.shared.isDarkMode ? Color(hex: "#102A52") : Color(hex: "#EAF3FF") }
    static var secondarySoft: Color { PharmacyAppSettings.shared.isDarkMode ? Color(hex: "#24204D") : Color(hex: "#F0ECFF") }
    static var successSoft: Color { PharmacyAppSettings.shared.isDarkMode ? Color(hex: "#123D36") : Color(hex: "#E8F8F0") }
    static var warningSoft: Color { PharmacyAppSettings.shared.isDarkMode ? Color(hex: "#4A3015") : Color(hex: "#FFF1E5") }
    static var mutedSurface: Color { PharmacyAppSettings.shared.isDarkMode ? Color(hex: "#132238") : Color(hex: "#F3F7FD") }
    static var textPrimary: Color { PharmacyAppSettings.shared.isDarkMode ? Color(hex: "#F8FBFF") : Color(hex: "#071833") }
    static var textSecondary: Color { PharmacyAppSettings.shared.isDarkMode ? Color(hex: "#9DAEC8") : Color(hex: "#5C6D86") }
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
