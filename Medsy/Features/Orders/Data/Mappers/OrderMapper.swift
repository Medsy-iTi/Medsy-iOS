//
//  OrderMapper.swift
//  Medsy
//
//  Created by Ahmed Elkady on 21/07/2026.
//

import Foundation

enum OrderMapper {
    private static let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        formatter.locale = Locale(identifier: "en_US_POSIX")
        return formatter
    }()

    static func mapToEntity(_ dto: OrderDTO) -> OrderEntity {
        let fulfillmentType = fulfillmentType(for: dto)
        return OrderEntity(
            id: dto.id,
            orderNumber: dto.id,
            pharmacyName: dto.pharmacyName ?? String(
                format: "orders.pharmacy_fallback".localized,
                dto.pharmacyId
            ),
            status: OrderStatus(rawValue: dto.status),
            fulfillmentType: fulfillmentType,
            date: date(from: dto.date),
            totalPrice: dto.totalPrice,
            itemCount: dto.items.reduce(0) { $0 + $1.quantity }
        )
    }

    static func mapToDetailEntity(_ dto: OrderDTO) -> OrderDetailEntity {
        let items = dto.items.map(mapToDetailItemEntity)
        let itemsSubtotal = dto.itemsSubtotal
            ?? items.reduce(0) { $0 + ($1.unitPrice * Double($1.quantity)) }
        let fulfillmentType = fulfillmentType(for: dto)
        return OrderDetailEntity(
            id: dto.id,
            orderNumber: dto.id,
            pharmacyName: dto.pharmacyName ?? String(
                format: "orders.pharmacy_fallback".localized,
                dto.pharmacyId
            ),
            pharmacyId: dto.pharmacyId,
            status: OrderStatus(rawValue: dto.status),
            fulfillmentType: fulfillmentType,
            date: date(from: dto.date),
            items: items,
            itemsSubtotal: itemsSubtotal,
            deliveryFee: fulfillmentType == .delivery ? dto.deliveryFee : nil,
            totalPrice: dto.totalPrice
        )
    }

    static func mapToPagedResult(_ page: PageDTO<OrderDTO>) -> PagedResult<OrderEntity> {
        PagedResult(
            items: page.content.map(mapToEntity),
            page: page.number ?? 0,
            size: page.size ?? page.content.count,
            totalElements: page.totalElements,
            totalPages: page.totalPages,
            isLast: page.last
        )
    }

    private static func mapToDetailItemEntity(_ dto: OrderItemDTO) -> OrderDetailItemEntity {
        OrderDetailItemEntity(
            id: dto.id,
            productId: dto.productId,
            productName: dto.productName ?? String(
                format: "orders.product_fallback".localized,
                dto.productId
            ),
            originalProductName: dto.originalProductName,
            quantity: dto.quantity,
            unitPrice: dto.unitPrice
        )
    }

    private static func fulfillmentType(for dto: OrderDTO) -> OrderFulfillmentType {
        OrderFulfillmentType(
            rawValue: dto.fulfillmentType,
            hasDeliveryCoordinates: dto.deliveryLatitude != nil && dto.deliveryLongitude != nil
        )
    }

    private static func date(from string: String) -> Date {
        dateFormatter.date(from: string) ?? Date()
    }
}
