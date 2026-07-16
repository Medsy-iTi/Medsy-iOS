//
//  PharmacyView+Localization.swift
//  Medsy-Pharmacy
//
//  Created by Ahmed Elkady on 17/07/2026.
//

import SwiftUI

extension View {
    func pharmacyLocalizedEnvironment() -> some View {
        modifier(PharmacyLocalizationModifier())
    }
}

private struct PharmacyLocalizationModifier: ViewModifier {
    @Environment(LanguageManager.self) private var languageManager

    func body(content: Content) -> some View {
        content
            .environment(\.layoutDirection, languageManager.isRTL ? .rightToLeft : .leftToRight)
            .environment(\.locale, languageManager.currentLanguage.locale)
    }
}
