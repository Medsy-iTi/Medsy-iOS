//
//  String+Localized.swift
//  Medsy
//
//  Created by Ahmed Elkady on 13/07/2026.
//

import Foundation


extension String {

    var localized: String {
        NSLocalizedString(self, bundle: .localizedBundle, comment: "")
    }

    func localized(_ args: CVarArg...) -> String {
        String(format: self.localized, arguments: args)
    }
}
