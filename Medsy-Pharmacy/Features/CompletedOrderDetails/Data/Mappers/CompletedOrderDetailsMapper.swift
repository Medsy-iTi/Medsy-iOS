//
//  CompletedOrderMapper.swift
//  Medsy
//

import Foundation

enum CompletedOrderDetailsMapper {
    private static let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        formatter.locale = Locale(identifier: "en_US_POSIX")
        return formatter
    }()

    static func mapToEntity(_ dto: CompletedOrderDetailsDTO) -> CompletedOrderDetailsEntity {
        CompletedOrderDetailsEntity(
            id: dto.id,
            customerId: dto.customerId,
            customerName: dto.customerName,
            pharmacyId: dto.pharmacyId,
            pharmacyName: dto.pharmacyName,
            pharmacyAddress: dto.pharmacyAddress,
            pharmacyPhone: dto.pharmacyPhone,
            pharmacistName: dto.pharmacistName,
            offerId: dto.offerId,
            subTotal: dto.subTotal,
            deliveryFee: dto.deliveryFee,
            total: dto.total,
            deliveryLatitude: dto.deliveryLatitude,
            deliveryLongitude: dto.deliveryLongitude,
            createdAt: date(from: dto.createdAt),
            items: dto.items.map(mapItem)
        )
    }

    private static func mapItem(_ dto: CompletedOrderItemDTO) -> CompletedOrderDetailsItemEntity {
        CompletedOrderDetailsItemEntity(
            id: dto.id,
            productId: dto.productId,
            productName: dto.productName,
            imageUrl: dto.imageUrl,
            quantity: dto.quantity,
            unitPrice: dto.unitPrice,
            totalPrice: dto.totalPrice
        )
    }

    private static func date(from string: String) -> Date {
        dateFormatter.date(from: string) ?? Date()
    }
}
