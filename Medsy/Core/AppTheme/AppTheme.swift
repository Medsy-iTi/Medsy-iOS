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
