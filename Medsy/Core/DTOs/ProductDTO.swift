//
//  APIResponseDTO.swift
//  Medsy
//
//  Created by Shahudaa on 16/07/2026.
//

import Foundation

struct APIResponseDTO<T: Decodable>: Decodable {
    let success: Bool
    let message: String
    let data: T?
}


struct PageDTO<T: Decodable>: Decodable {
	let content: [T]
	let totalElements: Int?
	let totalPages: Int?
	let number: Int?
	let size: Int?
	let last: Bool?
	let first: Bool?
	let numberOfElements: Int?
	let empty: Bool?

    private enum CodingKeys: String, CodingKey {
        case content
        case totalElements
        case totalPages
        case number
        case size
        case pageNumber
        case pageSize
        case last
        case first
        case numberOfElements
        case empty
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        content = try container.decode([T].self, forKey: .content)
        totalElements = try container.decodeIfPresent(Int.self, forKey: .totalElements)
        totalPages = try container.decodeIfPresent(Int.self, forKey: .totalPages)
        number = try container.decodeIfPresent(Int.self, forKey: .number)
            ?? container.decodeIfPresent(Int.self, forKey: .pageNumber)
        size = try container.decodeIfPresent(Int.self, forKey: .size)
            ?? container.decodeIfPresent(Int.self, forKey: .pageSize)
        last = try container.decodeIfPresent(Bool.self, forKey: .last)
        first = try container.decodeIfPresent(Bool.self, forKey: .first)
        numberOfElements = try container.decodeIfPresent(Int.self, forKey: .numberOfElements)
        empty = try container.decodeIfPresent(Bool.self, forKey: .empty)
    }
}

struct ProductDTO: Decodable {
	let id: Int
	let name: String
	let arabicName: String?
	let scientificName: String?
	let price: Double
	let imageUrl: String?
	let categoryId: Int?
	let categoryName: String?
	let company: String?
	let route: String?
	
	let barcode: String?
	let dosageForm: String?
	let form: String?
	let strength: String?
	let packSize: String?
	let isPrescription: Bool?
	let isActive: Bool?
	let description: String?
	let badgeText: String?
	let badgeColor: String?
	
	let productName: String?
	let scientificCategory: String?
	let consumerCategory: String?
}
