//
//  View+Localization.swift
//  Medsy
//
//  Created by Ahmed Elkady on 13/07/2026.
//

import SwiftUI


extension View {

    func localizedEnvironment() -> some View {
        modifier(LocalizationModifier())
    }
}


private struct LocalizationModifier: ViewModifier {

    @Environment(LanguageManager.self) private var languageManager

    func body(content: Content) -> some View {
        content
            .environment(\.layoutDirection, languageManager.isRTL ? .rightToLeft : .leftToRight)
            .environment(\.locale, languageManager.currentLanguage.locale)
    }
}
