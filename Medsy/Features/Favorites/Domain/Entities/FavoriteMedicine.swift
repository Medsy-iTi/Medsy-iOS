//
//  FavoriteMedicine.swift
//  Medsy
//
//  Created by Ehab Salah on 13/08/2026.
//

import Foundation

struct FavoriteMedicine: Identifiable, Equatable, Sendable {
    let id: Int
    let name: String
    let arabicName: String
    let scientificName: String
    let price: Double
    let imageURL: String?
    let categoryID: Int
    let categoryName: String
    let company: String
    let route: String
    let createdAt: Date

    init(
        id: Int,
        name: String,
        arabicName: String,
        scientificName: String,
        price: Double,
        imageURL: String?,
        categoryID: Int,
        categoryName: String,
        company: String,
        route: String,
        createdAt: Date = Date()
    ) {
        self.id = id
        self.name = name
        self.arabicName = arabicName
        self.scientificName = scientificName
        self.price = price
        self.imageURL = imageURL
        self.categoryID = categoryID
        self.categoryName = categoryName
        self.company = company
        self.route = route
        self.createdAt = createdAt
    }
}
