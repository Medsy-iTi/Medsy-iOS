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
    static var bg: Color { AppSettings.shared.isDarkMode ? Color(hex: "#1C1C1C") : Color(hex: "#F7F9F9") }
    static var surface: Color { AppSettings.shared.isDarkMode ? Color(hex: "#1C1C1C") : Color(hex: "#FFFFFF") }
    static var card: Color { AppSettings.shared.isDarkMode ? Color(hex: "#1C1C1C") : Color(hex: "#FFFFFF") }
    static var border: Color { Color(hex: "#E0E0E0") }
    
    static var green: Color { Color(hex: "#1E7B4D") }
    static let darkGreen = Color(hex: "#158F73")
    static let lightGreen = Color(hex: "#E8F8F4")
    static let white = Color(hex: "#FFFFFF")
  
    static var textPrim: Color { AppSettings.shared.isDarkMode ? Color(hex: "#FFFFFF") : Color(hex: "#1C1C1C") }
    static var textSec: Color { Color(hex: "#6B7280") }
    static var hintPlaceholder: Color {
        AppSettings.shared.isDarkMode ? Color(hex: "#9CA3AF") : Color(hex: "#6B7280")
    }
    
    static var btnBg: Color { green }
    static var btnText: Color { white }

    static var tagNew: Color { green }
    static let tagSold = Color(hex: "#EF4444")
    static let successGreen = Color(hex: "#22C55E")
    static let errorRed = Color(hex: "#EF4444")
    static let warningYellow = Color(hex: "#F59E0B")
    
    static var pill: Color { lightGreen }
    static var pillSel: Color { green }

    static var warningBg: Color { lightGreen }
    static var warningBorder: Color { warningYellow }

    static func serif(_ size: CGFloat, _ weight: Font.Weight = .regular) -> Font {
        Font.system(size: size, weight: weight, design: .serif)
    }

    static func sans(_ size: CGFloat, _ weight: Font.Weight = .regular) -> Font {
        Font.system(size: size, weight: weight)
    }


	static var danger: Color { errorRed }


	static var skeleton: Color { lightGreen }

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
