//
//  CompletedOrderMapper.swift
//  Medsy
//
//  Created by Shahudaa on 26/07/2026.
//


import Foundation

enum CompletedOrderMapper {

    private static let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        formatter.calendar = Calendar(identifier: .gregorian)
        formatter.timeZone = TimeZone(identifier: "UTC")
        return formatter
    }()

    static func map(_ dto: CompletedOrderItemDTO) -> CompletedOrderItem {
        CompletedOrderItem(
            id: dto.id,
            productId: dto.productId,
            productName: dto.productName,
            imageUrl: dto.imageUrl,
            quantity: dto.quantity,
            unitPrice: dto.unitPrice,
            totalPrice: dto.totalPrice
        )
    }

    static func map(_ dto: CompletedOrderDTO) -> CompletedOrder {
        CompletedOrder(
            id: dto.id,
            customerId: dto.customerId,
            customerName: dto.customerName,
            pharmacyId: dto.pharmacyId,
            pharmacyName: dto.pharmacyName,
            pharmacyAddress: dto.pharmacyAddress,
            pharmacyPhone: dto.pharmacyPhone,
            pharmacistId: dto.pharmacistId,
            pharmacistName: dto.pharmacistName,
            offerId: dto.offerId,
            subTotal: dto.subTotal,
            deliveryFee: dto.deliveryFee,
            total: dto.total,
            deliveryLatitude: dto.deliveryLatitude,
            deliveryLongitude: dto.deliveryLongitude,
            createdAt: dateFormatter.date(from: dto.createdAt) ?? Date(),
            items: dto.items.map(map)
        )
    }

    static func map(_ dto: PaginatedResponseDTO<CompletedOrderDTO>) -> PaginatedResult<CompletedOrder> {
        PaginatedResult(
            content: dto.content.map(map),
            pageNumber: dto.pageNumber,
            pageSize: dto.pageSize,
            totalElements: dto.totalElements,
            totalPages: dto.totalPages,
            isLast: dto.last
        )
    }
}
