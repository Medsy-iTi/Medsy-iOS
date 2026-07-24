//
//  MedicineAnalyzeProductDisplay.swift
//  Medsy
//
//  Created by Ehab Salah on 23/07/2026.
//

import Foundation

struct MedicineAnalyzeProductDisplay: Identifiable, Equatable {
    let id: String
    let name: String
    let productName: String
    let strength: String?
    let packSize: String
    let form: String
    let price: Double
    let scientificName: String
    let scientificCategory: String
    let consumerCategory: String
    let company: String
    let description: String
    let imageURL: String?

    var details: String {
        [strength, form, packSize.isEmpty ? nil : packSize]
            .compactMap { $0 }
            .filter { !$0.isEmpty }
            .joined(separator: " • ")
    }

    var cartItem: CartDisplayItem {
        CartDisplayItem(
            id: id,
            productID: Int64(id),
            name: name,
            dosageInfo: details,
            unitPrice: price,
            quantity: 1,
            imageUrl: imageURL
        )
    }
}
