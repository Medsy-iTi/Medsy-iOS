//
//  PaymentDTOs.swift
//  Medsy
//
//  Created by Ahmed Elkady on 11/08/2026.
//

import Foundation

typealias MasterOrderPaymentResponseDTO = APIResponseDTO<MasterOrderPaymentDTO>
typealias PaymentIntentResponseDTO = APIResponseDTO<PaymentIntentDTO>

struct MasterOrderPaymentDTO: Decodable, Equatable {
    let id: Int
    let paymentMethod: String
    let paymentStatus: String
    let orderStatus: String
    let paymentExpiresAt: String?
    let paidAt: String?
}

struct CreatePaymentIntentRequestDTO: Encodable, Equatable {
    let orderId: Int
}

struct PaymentIntentDTO: Decodable, Equatable {
    let paymentIntentId: String
    let clientSecret: String
}
