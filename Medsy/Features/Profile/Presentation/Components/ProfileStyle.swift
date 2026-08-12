//
//  ProfileStyle.swift
//  Medsy
//
//  Created by Ahmed Elkady on 15/07/2026.
//

import SwiftUI

enum ProfileStyle {
    static var background: Color { AppColor.background }
    static var headerTop: Color { AppColor.primaryContainer }
    static var headerBottom: Color { AppColor.background }
    static var card: Color { AppColor.surface }
    static var border: Color { AppColor.outlineVariant }
    static var primaryText: Color { AppColor.onSurface }
    static var secondaryText: Color { AppColor.onSurfaceVariant }
    static var disabledPrimaryText: Color { AppColor.onSurface.opacity(0.38) }
    static var disabledSecondaryText: Color { AppColor.onSurfaceVariant.opacity(0.32) }
    static var tabText: Color { AppColor.onSurfaceVariant }
    static var green: Color { AppColor.green }
    static var red: Color { AppColor.error }
    static var redBackground: Color { AppColor.errorContainer }
    static var redBorder: Color { AppColor.error }

    static func border(isDarkMode: Bool) -> Color {
        isDarkMode ? Color(hex: "#3F4A44") : Color(hex: "#D9E2DC")
    }

    static func primaryText(isDarkMode: Bool) -> Color {
        isDarkMode ? Color(hex: "#F5FAF7") : Color(hex: "#181C19")
    }

    static func secondaryText(isDarkMode: Bool) -> Color {
        isDarkMode ? Color(hex: "#C9D3CD") : Color(hex: "#414943")
    }

    static func disabledPrimaryText(isDarkMode: Bool) -> Color {
        primaryText(isDarkMode: isDarkMode).opacity(isDarkMode ? 0.38 : 0.34)
    }

    static func disabledSecondaryText(isDarkMode: Bool) -> Color {
        secondaryText(isDarkMode: isDarkMode).opacity(isDarkMode ? 0.34 : 0.30)
    }
}
