//
//  PharmacyString+Localized.swift
//  Medsy-Pharmacy
//
//  Created by Ahmed Elkady on 17/07/2026.
//

import Foundation

extension String {
    var localized: String {
        PharmacyBundleLanguage.localizedString(for: self, value: nil, table: nil)
    }

    func localized(_ arguments: CVarArg...) -> String {
        String(format: localized, locale: Locale.current, arguments: arguments)
    }
}
