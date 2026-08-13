//
//  FavoriteMedicineModel.swift
//  Medsy
//
//  Created by Ehab Salah on 13/08/2026.
//

import Foundation
import SwiftData

@Model
final class FavoriteMedicineModel {
    @Attribute(.unique) var storageKey: String
    var accountIdentifier: String
    var productID: Int
    var name: String
    var arabicName: String
    var scientificName: String
    var price: Double
    var imageURL: String?
    var categoryID: Int
    var categoryName: String
    var company: String
    var route: String
    var createdAt: Date

    init(accountIdentifier: String, record: FavoriteMedicineRecord) {
        storageKey = Self.storageKey(accountIdentifier: accountIdentifier, productID: record.productID)
        self.accountIdentifier = accountIdentifier
        productID = record.productID
        name = record.name
        arabicName = record.arabicName
        scientificName = record.scientificName
        price = record.price
        imageURL = record.imageURL
        categoryID = record.categoryID
        categoryName = record.categoryName
        company = record.company
        route = record.route
        createdAt = record.createdAt
    }

    func update(from record: FavoriteMedicineRecord) {
        name = record.name
        arabicName = record.arabicName
        scientificName = record.scientificName
        price = record.price
        imageURL = record.imageURL
        categoryID = record.categoryID
        categoryName = record.categoryName
        company = record.company
        route = record.route
        createdAt = record.createdAt
    }

    static func storageKey(accountIdentifier: String, productID: Int) -> String {
        "\(accountIdentifier)|\(productID)"
    }
}
