// PharmacyProductSearchDTO.swift

import Foundation

struct PharmacyProductDTO: Decodable, Equatable, Identifiable, Sendable {
    let id: Int
    let name: String?
    let productName: String?
    let strength: String?
    let packSize: String?
    let form: String?
    let price: Double?
    let scientificName: String?
    let scientificCategory: String?
    let categoryId: Int?
    let consumerCategory: String?
    let company: String?
    let route: String?
    let description: String?
    let imageUrl: String?
}
