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

    func localizedNavigationBackButton(action: @escaping () -> Void) -> some View {
        modifier(LocalizedNavigationBackButtonModifier(action: action))
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

private struct LocalizedNavigationBackButtonModifier: ViewModifier {

    @Environment(LanguageManager.self) private var languageManager
    let action: () -> Void

    func body(content: Content) -> some View {
        content
            .navigationBarBackButtonHidden()
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button(action: action) {
                        HStack(spacing: 4) {
                            Image(systemName: languageManager.isRTL ? "chevron.forward" : "chevron.backward")
                                .font(.system(size: 15, weight: .semibold))

                            Text("common.back".localized)
                        }
                        .foregroundStyle(AppColor.green)
                    }
                }
            }
    }
}
