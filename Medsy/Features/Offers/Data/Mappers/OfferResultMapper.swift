//
//  OfferResultMapper.swift
//  Medsy
//
//  Created by Antoneos Philip on 25/07/2026.
//

import Foundation

enum OfferResultMapper {
    static func map(_ dto: OfferResultResponseDTO) -> OfferResult {
        let items = dto.items.map { itemDTO in
            OfferResultItem(
                requestItemId: itemDTO.requestItemId,
                productId: itemDTO.productId,
                productName: itemDTO.productName,
                imageUrl: itemDTO.imageUrl,
                unitPrice: itemDTO.unitPrice,
                isAlternative: itemDTO.isAlternative,
                isAvailable: itemDTO.isAvailable
            )
        }
        let calculatedTotal = items.reduce(0.0) { $0 + ($1.isAvailable ? $1.unitPrice : 0.0) }
        let total = dto.totalPrice > 0 ? dto.totalPrice : calculatedTotal

        return OfferResult(
            items: items,
            totalPrice: total,
            prescriptionUrl: dto.prescriptionUrl
        )
    }

    static func map(_ dto: ConfirmOfferResponseDTO, requestId: Int) -> ConfirmOfferResult {
        let orders = [
            ConfirmOfferOrder(
                orderId: dto.masterOrderId,
                pharmacyId: 0,
                pharmacyName: "",
                itemIds: []
            )
        ]
        return ConfirmOfferResult(
            requestId: requestId,
            orders: orders
        )
    }
}
