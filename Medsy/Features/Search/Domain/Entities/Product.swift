//
//  Product.swift
//  Medsy
//
//  Created by Shahudaa on 16/07/2026.
//

import Foundation

struct Product: Identifiable, Equatable {
    let id: Int
    let name: String
    let arabicName: String
    let scientificName: String
    let price: Double
    let imageUrl: String?
    let categoryId: Int
    let categoryName: String
    let company: String
    let route: String

    func displayName(isRTL: Bool) -> String {
        isRTL && !arabicName.isEmpty ? arabicName : name
    }
}
