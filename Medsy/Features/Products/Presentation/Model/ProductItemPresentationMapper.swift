//  ProductItemPresentationMapper.swift
//  Medsy
//
//  Created by Antoneos Philip on 17/07/2026.

import SwiftUI

enum ProductItemPresentationMapper {
    static func map(_ item: ProductItem, isRTL: Bool) -> MedsyProduct {
        let (englishShortName, dosage) = parseName(item.name)
        let displayName = isRTL && !item.arabicName.isEmpty && item.arabicName != item.name ? item.arabicName : englishShortName
        return MedsyProduct(
            id: String(item.id),
            name: displayName,
            dosageInfo: dosage,
            scientificName: item.scientificName,
            price: item.price,
            imageUrl: item.imageUrl,
            badgeText: item.company,
            badgeColor: AppColor.green,
            categoryName: item.categoryName
        )
    }

    static func favorite(_ item: ProductItem) -> FavoriteMedicine {
        FavoriteMedicine(
            id: item.id,
            name: item.name,
            arabicName: item.arabicName,
            scientificName: item.scientificName,
            price: item.price,
            imageURL: item.imageUrl,
            categoryID: item.categoryId,
            categoryName: item.categoryName,
            company: item.company,
            route: item.route
        )
    }

    private static let dosageStartPatterns: Set<String> = [
        "MG", "MCG", "ML", "IU", "G", "MG/ML", "MCMOL", "MMOL", "MEQ"
    ]

    private static func parseName(_ fullName: String) -> (name: String, dosage: String) {
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
