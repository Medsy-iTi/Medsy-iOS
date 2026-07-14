//
//  Bundle+Language.swift
//  Medsy
//
//  Created by Ahmed Elkady on 13/07/2026.
//

import Foundation

enum BundleLanguage {

    static func setLanguage(_ languageCode: String) {
        guard
            let path = Bundle.main.path(forResource: languageCode, ofType: "lproj"),
            let bundle = Bundle(path: path)
        else {
            return
        }

        LanguageBundle.active = bundle

        object_setClass(Bundle.main, LanguageBundle.self)
    }
}

private final class LanguageBundle: Bundle, @unchecked Sendable {

    static var active: Bundle = .main

    override func localizedString(
        forKey key: String,
        value: String?,
        table tableName: String?
    ) -> String {
        LanguageBundle.active.localizedString(forKey: key, value: value, table: tableName)
    }
}


extension Bundle {
    static var localizedBundle: Bundle { .main }
}
