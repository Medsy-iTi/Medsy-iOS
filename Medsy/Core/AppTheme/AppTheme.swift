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
    @Published var isDarkMode: Bool = false
}

enum AppColor {
    static var bg: Color { AppSettings.shared.isDarkMode ? Color(hex: "#0F0F0F") : Color(hex: "#FAFAF8") }
    static var surface: Color { AppSettings.shared.isDarkMode ? Color(hex: "#1A1A1A") : Color(hex: "#F5F7F8") }
    static var card: Color { AppSettings.shared.isDarkMode ? Color(hex: "#222222") : Color(hex: "#FFFFFF") }
    static var border: Color { AppSettings.shared.isDarkMode ? Color(white: 1, opacity: 0.12) : Color(white: 0, opacity: 0.08) }
    
    static var green: Color { AppSettings.shared.isDarkMode ? Color(hex: "#34C759") : Color(hex: "#2A8754") }
    static let white = Color.white
  
    static var textPrim: Color { AppSettings.shared.isDarkMode ? Color(hex: "#F5F5F7") : Color(hex: "#1A1A1A") }
    static var textSec: Color { AppSettings.shared.isDarkMode ? Color(white: 1, opacity: 0.55) : Color(white: 0, opacity: 0.45) }
    
    static var btnBg: Color { green }
    static var btnText: Color { Color.white }

    static var tagNew: Color { green }
    static let tagSold = Color(hex: "#C0392B")
    
    static var pill: Color { AppSettings.shared.isDarkMode ? Color(white: 1, opacity: 0.08) : Color(white: 0, opacity: 0.06) }
    static var pillSel: Color { green }

    static var warningBg: Color { AppSettings.shared.isDarkMode ? Color(hex: "#2C1A0C") : Color(hex: "#FFF5EC") }
    static var warningBorder: Color { AppSettings.shared.isDarkMode ? Color(hex: "#8B9E7A") : Color(hex: "#829E6C") }

    static func serif(_ size: CGFloat, _ weight: Font.Weight = .regular) -> Font {
        Font.system(size: size, weight: weight, design: .serif)
    }

    static func sans(_ size: CGFloat, _ weight: Font.Weight = .regular) -> Font {
        Font.system(size: size, weight: weight)
    }


	static var danger: Color { AppSettings.shared.isDarkMode ? Color(hex: "#EB6666") : Color(hex: "#D13D3D") }


	static var skeleton: Color { AppSettings.shared.isDarkMode ? Color(hex: "#1F3029") : Color(hex: "#E6F0EB") }

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
