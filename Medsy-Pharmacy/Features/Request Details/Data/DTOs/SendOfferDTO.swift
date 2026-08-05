//
//  SendOfferDTO.swift
//  Medsy-Pharmacy
//
//  Created by Antoneos Philip on 25/07/2026.
//

import Foundation

struct SendOfferRequestDTO: Encodable, Equatable {
    let items: [SendOfferItemDTO]
}

struct SendOfferItemDTO: Encodable, Equatable {
    let requestItemId: Int
    let productId: Int
}

struct SendOfferResponseDTO: Decodable, Equatable {
    let id: Int?
    let requestId: Int?
    let status: String?
}
