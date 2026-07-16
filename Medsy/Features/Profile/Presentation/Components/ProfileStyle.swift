//
//  ProfileStyle.swift
//  Medsy
//
//  Created by Ahmed Elkady on 15/07/2026.
//

import SwiftUI

enum ProfileStyle {
    static var background: Color { isDarkMode ? Color(hex: "#141E18") : Color(hex: "#FAFAF8") }
    static var headerTop: Color { isDarkMode ? Color(hex: "#102A1C") : Color(hex: "#EAF6EF") }
    static var headerBottom: Color { isDarkMode ? Color(hex: "#141E18") : Color(hex: "#FAFAF8") }
    static var card: Color { isDarkMode ? Color(hex: "#1A2920") : Color(hex: "#FFFFFF") }
    static var border: Color { isDarkMode ? Color(hex: "#283D32") : Color(white: 0, opacity: 0.08) }
    static var primaryText: Color { isDarkMode ? Color(hex: "#EEF7F2") : Color(hex: "#1A1A1A") }
    static var secondaryText: Color { isDarkMode ? Color(hex: "#9AB5A8") : Color(white: 0, opacity: 0.52) }
    static var tabText: Color { isDarkMode ? Color(hex: "#B8C6C1") : Color(white: 0, opacity: 0.58) }
    static let green = Color(hex: "#0D8653")
    static let red = Color(hex: "#EF4444")
    static var redBackground: Color { isDarkMode ? Color(hex: "#3B1111") : Color(hex: "#FEF2F2") }
    static var redBorder: Color { isDarkMode ? Color(hex: "#7F1D1D") : Color(hex: "#FCA5A5") }

    private static var isDarkMode: Bool {
        AppSettings.shared.isDarkMode
    }
}
