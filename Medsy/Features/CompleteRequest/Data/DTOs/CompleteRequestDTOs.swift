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
    let notes: String
    let paymentMethod: String
    let prescriptionData: Data?

    private enum CodingKeys: String, CodingKey {
        case deliveryLatitude
        case deliveryLongitude
        case deliveryAddress
        case notes
        case paymentMethod
    }

    init(input: SubmitCompleteRequestInput) {
        deliveryLatitude = input.deliveryLatitude
        deliveryLongitude = input.deliveryLongitude
        deliveryAddress = input.deliveryAddress
        notes = input.notes
        paymentMethod = input.paymentMethod
        prescriptionData = input.prescriptionData
    }
}

struct CompleteRequestResponseDTO: Decodable, Equatable {
    let id: Int
    let customerId: Int
    let customerName: String
    let customerPhone: String
    let deliveryLatitude: Double
    let deliveryLongitude: Double
    let deliveryAddress: String
    let status: String
    let createdAt: String
    let items: [CompleteRequestResponseItemDTO]
    let prescriptionUrl: String?
    let notes: String?
}

struct CompleteRequestResponseItemDTO: Decodable, Equatable {
    let id: Int
    let productId: Int
    let imageUrl: String?
    let productName: String
    let strength: String
    let packSize: String
    let form: String
    let quantity: Int
    let unitPrice: Double
}
