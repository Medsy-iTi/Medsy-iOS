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
            customerName: dto.customerName,
            customerPhone: dto.customerPhone,
            deliveryLatitude: dto.deliveryLatitude,
            deliveryLongitude: dto.deliveryLongitude,
            deliveryAddress: dto.deliveryAddress,
            status: dto.status,
            createdAt: createdAt,
            items: dto.items.map {
                SubmittedMedicineRequestItem(
                    id: $0.id,
                    productID: $0.productId,
                    quantity: $0.quantity,
                    imageURL: $0.imageUrl,
                    productName: $0.productName,
                    strength: $0.strength,
                    packSize: $0.packSize,
                    form: $0.form,
                    unitPrice: $0.unitPrice
                )
            },
            prescriptionURL: dto.prescriptionUrl,
            notes: dto.notes
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
