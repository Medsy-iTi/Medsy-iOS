//
//  CompleteRequestDTOs.swift
//  Medsy
//
//  Created by Ehab Salah on 24/07/2026.
//

import Foundation

typealias SubmitCompleteRequestResponseDTO = APIResponseDTO<CompleteRequestResponseDTO>

struct CompleteRequestDTO: Encodable, Equatable {
    let deliveryLatitude: Double
    let deliveryLongitude: Double
    let deliveryAddress: String

    init(input: SubmitCompleteRequestInput) {
        deliveryLatitude = input.deliveryLatitude
        deliveryLongitude = input.deliveryLongitude
        deliveryAddress = input.deliveryAddress
    }
}

struct CompleteRequestResponseDTO: Decodable, Equatable {
    let id: Int
    let customerId: Int
    let deliveryLatitude: Double
    let deliveryLongitude: Double
    let deliveryAddress: String
    let status: String
    let createdAt: String
    let items: [CompleteRequestResponseItemDTO]
}

struct CompleteRequestResponseItemDTO: Decodable, Equatable {
    let id: Int
    let productId: Int
    let quantity: Int
}
