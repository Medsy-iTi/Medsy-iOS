//
//  CompleteRequestMapper.swift
//  Medsy
//
//  Created by Ehab Salah on 24/07/2026.
//

import Foundation

enum CompleteRequestMapper {
    static func map(_ dto: CompleteRequestResponseDTO) throws -> SubmittedMedicineRequest {
        guard let createdAt = date(from: dto.createdAt) else {
            throw NetworkError.decodingFailed
        }
        
        return SubmittedMedicineRequest(
            id: dto.id,
            customerID: dto.customerId,
            deliveryLatitude: dto.deliveryLatitude,
            deliveryLongitude: dto.deliveryLongitude,
            deliveryAddress: dto.deliveryAddress,
            status: dto.status,
            createdAt: createdAt,
            items: dto.items.map {
                SubmittedMedicineRequestItem(
                    id: $0.id,
                    productID: $0.productId,
                    quantity: $0.quantity
                )
            }
        )
    }
    
    private static func date(from value: String) -> Date? {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.calendar = Calendar(identifier: .iso8601)
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSSSSSSS"
        
        return formatter.date(from: value)
    }
}
