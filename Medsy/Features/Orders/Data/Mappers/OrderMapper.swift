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

    private static let localDateTimeFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS"
        formatter.locale = Locale(identifier: "en_US_POSIX")
        return formatter
    }()

    private static let localDateTimeWithoutFractionFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
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
            itemCount: dto.items.reduce(0) { $0 + $1.quantity },
            itemImageURLs: dto.items.compactMap(\.imageUrl)
        )
    }

    static func mapToEntity(_ dto: MasterOrderDTO) -> OrderEntity {
        let items = dto.orderResponses.flatMap(\.items)
        let expiry = dto.paymentExpiresAt.map { date(from: $0) }
        return OrderEntity(
            id: dto.id,
            orderNumber: dto.id,
            pharmacyName: pharmacyName(from: dto.orderResponses),
            status: OrderStatus(rawValue: dto.orderStatus),
            fulfillmentType: OrderFulfillmentType(
                rawValue: dto.fulfillmentMethod,
                hasDeliveryCoordinates: false
            ),
            date: displayDate(paidAt: dto.paidAt, paymentExpiresAt: dto.paymentExpiresAt),
            totalPrice: dto.totalPrice,
            itemCount: items.reduce(0) { $0 + $1.quantity },
            itemImageURLs: items.compactMap(\.imageUrl),
            paymentMethod: MasterOrderPaymentMethod(rawValue: dto.paymentMethod.uppercased()) ?? .unknown,
            paymentStatus: dto.paymentStatus.flatMap {
                MasterOrderPaymentStatus(rawValue: $0.uppercased())
            } ?? .unpaid,
            paymentExpiresAt: expiry
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

    static func mapToDetailEntity(_ dto: MasterOrderDTO) -> OrderDetailEntity {
        let itemDTOs = dto.orderResponses.flatMap(\.items)
        let items = itemDTOs.map(mapToDetailItemEntity)
        let itemsSubtotal = items.reduce(0) { $0 + ($1.unitPrice * Double($1.quantity)) }
        let fulfillmentType = OrderFulfillmentType(
            rawValue: dto.fulfillmentMethod,
            hasDeliveryCoordinates: false
        )
        return OrderDetailEntity(
            id: dto.id,
            orderNumber: dto.id,
            pharmacyName: pharmacyName(from: dto.orderResponses),
            pharmacyId: dto.orderResponses.first?.pharmacyId ?? 0,
            status: OrderStatus(rawValue: dto.orderStatus),
            fulfillmentType: fulfillmentType,
            date: displayDate(paidAt: dto.paidAt, paymentExpiresAt: dto.paymentExpiresAt),
            items: items,
            itemsSubtotal: itemsSubtotal,
            deliveryFee: fulfillmentType == .delivery ? dto.deliveryFee : nil,
            totalPrice: dto.totalPrice,
            paymentMethod: MasterOrderPaymentMethod(rawValue: dto.paymentMethod.uppercased()) ?? .unknown,
            paymentStatus: dto.paymentStatus.flatMap {
                MasterOrderPaymentStatus(rawValue: $0.uppercased())
            } ?? .unpaid,
            paymentExpiresAt: dto.paymentExpiresAt.map { date(from: $0) }
        )
    }

    static func mapToPagedResult(_ page: PageDTO<OrderGroupDTO>) -> PagedResult<OrderEntity> {
        let orders = page.content.flatMap(\.orders)
        return PagedResult(
            items: orders.map(mapToEntity),
            page: page.number ?? 0,
            size: page.size ?? page.content.count,
            totalElements: page.totalElements,
            totalPages: page.totalPages,
            isLast: page.last
        )
    }

    static func mapToPagedResult(_ page: PageDTO<MasterOrderDTO>) -> PagedResult<OrderEntity> {
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
            unitPrice: dto.unitPrice,
            imageURL: dto.imageUrl
        )
    }

    private static func fulfillmentType(for dto: OrderDTO) -> OrderFulfillmentType {
        OrderFulfillmentType(
            rawValue: dto.fulfillmentType,
            hasDeliveryCoordinates: dto.deliveryLatitude != nil && dto.deliveryLongitude != nil
        )
    }

    private static func pharmacyName(from orders: [MasterOrderDraftDTO]) -> String {
        let names = orders.map(\.pharmacyName).filter { !$0.isEmpty }
        return names.isEmpty ? "orders.pharmacy_unknown".localized : names.joined(separator: " / ")
    }

    private static func displayDate(paidAt: String?, paymentExpiresAt: String?) -> Date {
        if let paidAt {
            return date(from: paidAt)
        }
        if let paymentExpiresAt {
            return date(from: paymentExpiresAt).addingTimeInterval(-15 * 60)
        }
        return Date()
    }

    private static func date(from string: String) -> Date {
        if let date = dateFormatter.date(from: string) {
            return date
        }

        let isoFormatter = ISO8601DateFormatter()
        isoFormatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        if let date = isoFormatter.date(from: string) {
            return date
        }

        isoFormatter.formatOptions = [.withInternetDateTime]
        if let date = isoFormatter.date(from: string) {
            return date
        }

        if let date = localDateTimeFormatter.date(from: normalizedLocalDateTime(string)) {
            return date
        }

        if let date = localDateTimeWithoutFractionFormatter.date(from: string) {
            return date
        }

        return Date()
    }

    private static func normalizedLocalDateTime(_ string: String) -> String {
        guard let dotIndex = string.firstIndex(of: ".") else { return string }

        let prefix = string[..<dotIndex]
        let fractionStart = string.index(after: dotIndex)
        let fractionalDigits = String(string[fractionStart...]
            .prefix(while: { $0.isNumber })
            .prefix(3))
        let paddedFraction = fractionalDigits.padding(
            toLength: 3,
            withPad: "0",
            startingAt: 0
        )

        return "\(prefix).\(paddedFraction)"
    }
}
