//
//  PharmacyAppLanguage.swift
//  Medsy-Pharmacy
//
//  Created by Ahmed Elkady on 17/07/2026.
//

import Foundation

enum PharmacyAppLanguage: String, CaseIterable {
    case arabic = "ar"
    case english = "en"

    var isRTL: Bool {
        self == .arabic
    }

    var locale: Locale {
        Locale(identifier: rawValue)
    }

    var toggled: PharmacyAppLanguage {
        self == .arabic ? .english : .arabic
    }
}
