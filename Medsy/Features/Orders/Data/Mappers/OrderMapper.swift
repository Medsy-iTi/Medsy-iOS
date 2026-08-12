//
//  OrderMapper.swift
//  Medsy
//
//  Created by Ahmed Elkady on 21/07/2026.
//

import Foundation

enum OrderMapper {
    static func mapToEntity(_ dto: MasterOrderDTO) -> OrderEntity {
        let pharmacies = dto.orderResponses.map(mapPharmacy)
        let allItems = pharmacies.flatMap(\.items)
        let pharmacyNames = uniquePharmacyNames(from: pharmacies)

        return OrderEntity(
            id: dto.id,
            orderNumber: dto.id,
            pharmacyName: pharmacyNames.first ?? "",
            status: OrderStatus(rawValue: dto.orderStatus),
            fulfillmentType: OrderFulfillmentType(
                rawValue: dto.fulfillmentMethod,
                hasDeliveryCoordinates: false
            ),
            date: displayDate(for: dto),
            totalPrice: dto.totalPrice,
            itemCount: allItems.reduce(0) { $0 + $1.quantity },
            itemImageURLs: allItems.compactMap(\.imageURL),
            requestID: dto.requestId,
            pharmacyNames: pharmacyNames,
            paymentMethod: dto.paymentMethod.flatMap(OrderPaymentMethod.init(rawValue:)),
            paymentStatus: dto.paymentStatus.flatMap(OrderPaymentStatus.init(rawValue:)),
            paymentExpiresAt: dto.paymentExpiresAt.flatMap(date),
            paidAt: dto.paidAt.flatMap(date)
        )
    }

    static func mapToDetailEntity(_ dto: MasterOrderDTO) -> OrderDetailEntity {
        let pharmacies = dto.orderResponses.map(mapPharmacy)
        let allItems = pharmacies.flatMap(\.items)
        let firstPharmacy = pharmacies.first
        let fulfillmentType = OrderFulfillmentType(
            rawValue: dto.fulfillmentMethod,
            hasDeliveryCoordinates: false
        )

        return OrderDetailEntity(
            id: dto.id,
            orderNumber: dto.id,
            pharmacyName: firstPharmacy?.pharmacyName ?? "",
            pharmacyId: firstPharmacy?.pharmacyId ?? 0,
            status: OrderStatus(rawValue: dto.orderStatus),
            fulfillmentType: fulfillmentType,
            date: displayDate(for: dto),
            items: allItems,
            itemsSubtotal: allItems.reduce(0) { $0 + ($1.unitPrice * Double($1.quantity)) },
            deliveryFee: fulfillmentType == .delivery ? dto.deliveryFee : nil,
            totalPrice: dto.totalPrice,
            requestID: dto.requestId,
            pharmacies: pharmacies,
            paymentMethod: dto.paymentMethod.flatMap(OrderPaymentMethod.init(rawValue:)),
            paymentStatus: dto.paymentStatus.flatMap(OrderPaymentStatus.init(rawValue:)),
            paymentExpiresAt: dto.paymentExpiresAt.flatMap(date),
            paidAt: dto.paidAt.flatMap(date)
        )
    }

    static func mapDeliveryLocation(_ dto: OrderRequestDetailDTO) throws -> OrderCoordinateEntity {
        guard let coordinate = coordinate(
            latitude: dto.deliveryLatitude,
            longitude: dto.deliveryLongitude
        ) else {
            throw OrderLocationError.locationUnavailable
        }
        return coordinate
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

    private static func mapPharmacy(_ dto: MasterOrderPharmacyDTO) -> OrderPharmacyEntity {
        OrderPharmacyEntity(
            id: dto.offerId,
            pharmacyId: dto.pharmacyId,
            pharmacyName: dto.pharmacyName,
            coordinate: coordinate(latitude: dto.latitude, longitude: dto.longitude),
            items: dto.items.map(mapItem)
        )
    }

    private static func mapItem(_ dto: MasterOrderItemDTO) -> OrderDetailItemEntity {
        let product = dto.product.map(mapProduct)
        let productName = dto.product?.productName
            ?? dto.product?.name
            ?? "orders.product_unavailable".localized
        let originalProductName = dto.product?.name == productName ? nil : dto.product?.name

        return OrderDetailItemEntity(
            id: dto.id,
            productId: dto.productId,
            productName: productName,
            originalProductName: originalProductName,
            quantity: dto.quantity,
            unitPrice: dto.unitPrice,
            imageURL: dto.product?.imageUrl,
            product: product
        )
    }

    private static func mapProduct(_ dto: MasterOrderProductDTO) -> OrderProductEntity {
        OrderProductEntity(
            id: dto.id,
            name: dto.name,
            productName: dto.productName,
            strength: dto.strength,
            packSize: dto.packSize,
            form: dto.form,
            price: dto.price,
            scientificName: dto.scientificName,
            company: dto.company,
            route: dto.route,
            description: dto.description,
            imageURL: dto.imageUrl
        )
    }

    private static func coordinate(latitude: Double?, longitude: Double?) -> OrderCoordinateEntity? {
        guard let latitude, let longitude,
              (-90...90).contains(latitude),
              (-180...180).contains(longitude) else {
            return nil
        }
        return OrderCoordinateEntity(latitude: latitude, longitude: longitude)
    }

    private static func uniquePharmacyNames(from pharmacies: [OrderPharmacyEntity]) -> [String] {
        var seen = Set<String>()
        return pharmacies.compactMap { pharmacy in
            guard !pharmacy.pharmacyName.isEmpty,
                  seen.insert(pharmacy.pharmacyName).inserted else {
                return nil
            }
            return pharmacy.pharmacyName
        }
    }

    private static func displayDate(for dto: MasterOrderDTO) -> Date {
        if let paidAt = dto.paidAt.flatMap(date) {
            return paidAt
        }
        if let expiresAt = dto.paymentExpiresAt.flatMap(date) {
            return expiresAt.addingTimeInterval(-15 * 60)
        }
        return Date()
    }

    private static func date(from string: String) -> Date? {
        let isoFormatter = ISO8601DateFormatter()
        isoFormatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        if let date = isoFormatter.date(from: string) {
            return date
        }

        isoFormatter.formatOptions = [.withInternetDateTime]
        if let date = isoFormatter.date(from: string) {
            return date
        }

        let normalized = normalizedLocalDateTime(string)
        for format in ["yyyy-MM-dd'T'HH:mm:ss.SSS", "yyyy-MM-dd'T'HH:mm:ss"] {
            let formatter = DateFormatter()
            formatter.dateFormat = format
            formatter.locale = Locale(identifier: "en_US_POSIX")
            formatter.timeZone = .current
            if let date = formatter.date(from: normalized) {
                return date
            }
        }

        return nil
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
