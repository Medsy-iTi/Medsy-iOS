//
//  AppLanguage.swift
//  Medsy
//
//  Created by Ahmed Elkady on 13/07/2026.
//

import Foundation

enum AppLanguage: String, CaseIterable, Identifiable {

    case english = "en"
    case arabic  = "ar"

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .english: return "English"
        case .arabic:  return "العربية"
        }
    }

    var isRTL: Bool { self == .arabic }


    var locale: Locale { Locale(identifier: rawValue) }

    var toggled: AppLanguage {
        switch self {
        case .english: return .arabic
        case .arabic:  return .english
        }
    }

    static var systemDefault: AppLanguage {
        let preferred = Locale.preferredLanguages.first ?? "en"
        let code = String(preferred.prefix(2))
        return AppLanguage(rawValue: code) ?? .english
    }
}
