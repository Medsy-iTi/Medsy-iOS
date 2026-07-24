//
//  ProductNameParser.swift
//  Medsy
//
//  Created by Medsy on 17/07/2026.
//

import Foundation

enum ProductNameParser {
    private static let dosageStartPatterns: Set<String> = [
        "MG", "MCG", "ML", "IU", "G", "MG/ML", "MCMOL", "MMOL", "MEQ"
    ]

    static func parseName(_ fullName: String) -> (name: String, dosage: String) {
        let tokens = fullName.components(separatedBy: " ")

        for (index, token) in tokens.enumerated() {
            let clean = token.trimmingCharacters(in: .punctuationCharacters)
            let startsWithDigit = clean.first?.isNumber == true
            let isDosageUnit = dosageStartPatterns.contains(clean.uppercased())

            if startsWithDigit || isDosageUnit {
                let namePart = tokens[..<index].joined(separator: " ")
                let dosagePart = tokens[index...].joined(separator: " ")
                return (namePart.isEmpty ? fullName : namePart, dosagePart)
            }
        }

        return (fullName, "")
    }
}
