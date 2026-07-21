//
//  PharmacyBundleLanguage.swift
//  Medsy-Pharmacy
//
//  Created by Ahmed Elkady on 17/07/2026.
//

import Foundation

enum PharmacyBundleLanguage {
    private static var bundle: Bundle?

    static func setLanguage(_ languageCode: String) {
        guard
            let path = Bundle.main.path(forResource: languageCode, ofType: "lproj"),
            let languageBundle = Bundle(path: path)
        else {
            bundle = nil
            return
        }

        bundle = languageBundle
    }

    static func localizedString(for key: String, value: String?, table: String?) -> String {
        bundle?.localizedString(forKey: key, value: value, table: table)
            ?? Bundle.main.localizedString(forKey: key, value: value, table: table)
    }
}
