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
        OrderEntity(
            id: dto.id,
            orderNumber: dto.id,
            pharmacyName: "Pharmacy #\(dto.pharmacyId)",
            status: OrderStatus(rawValue: dto.status),
            date: date(from: dto.date),
            totalPrice: dto.totalPrice,
            itemCount: dto.items.count
        )
    }

    static func mapToDetailEntity(_ dto: OrderDTO) -> OrderDetailEntity {
        OrderDetailEntity(
            id: dto.id,
            orderNumber: dto.id,
            pharmacyName: "Pharmacy #\(dto.pharmacyId)",
            status: OrderStatus(rawValue: dto.status),
            date: date(from: dto.date),
            items: dto.items.map(mapToDetailItemEntity),
            deliveryFee: nil,
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
            productName: "Product #\(dto.productId)",
            quantity: dto.quantity,
            unitPrice: dto.unitPrice
        )
    }

    private static func date(from string: String) -> Date {
        dateFormatter.date(from: string) ?? Date()
    }
}
