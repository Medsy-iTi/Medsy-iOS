//
//  PharmacyOrderMapper.swift
//  Medsy
//
//  Created by Shahudaa on 21/07/2026.
//


import Foundation

enum PharmacyOrderMapper {

    private static let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        formatter.calendar = Calendar(identifier: .gregorian)
        formatter.timeZone = TimeZone(identifier: "UTC")
        return formatter
    }()

    static func map(_ dto: PharmacyOrderDTO) -> PharmacyOrder {
        PharmacyOrder(
            id: dto.id,
            userId: dto.userId,
            pharmacyId: dto.pharmacyId,
            totalPrice: dto.totalPrice,
            deliveryCoordinate: (dto.deliveryLatitude, dto.deliveryLongitude),
            status: PharmacyOrderAPIStatus(rawValue: dto.status),
            date: dateFormatter.date(from: dto.date) ?? Date(),
            items: dto.items.map {
                PharmacyOrderLineItem(id: $0.id, productId: $0.productId, quantity: $0.quantity, unitPrice: $0.unitPrice)
            }
        )
    }

    static func map(_ dto: PharmacyMedicineRequestDTO) -> PharmacyOrder {
        let total = (dto.items ?? []).reduce(0.0) { $0 + (($1.unitPrice ?? 0.0) * Double($1.quantity)) }
        let parsedDate: Date = {
            guard let dateStr = dto.createdAt else { return Date() }
            let formatter = ISO8601DateFormatter()
            formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
            return formatter.date(from: dateStr) ?? Date()
        }()

        let items = (dto.items ?? []).map { item in
            PharmacyOrderLineItem(
                id: item.id,
                productId: item.productId,
                quantity: item.quantity,
                unitPrice: item.unitPrice ?? 0.0
            )
        }

        return PharmacyOrder(
            id: dto.id,
            userId: dto.customerId ?? 0,
            pharmacyId: 0,
            totalPrice: total,
            deliveryCoordinate: (dto.deliveryLatitude ?? 0.0, dto.deliveryLongitude ?? 0.0),
            status: PharmacyOrderAPIStatus(rawValue: dto.status),
            date: parsedDate,
            items: items
        )
    }

    static func map(_ dto: PageResponseDTO<PharmacyOrderDTO>) -> PharmacyOrdersPage {
        PharmacyOrdersPage(
            orders: dto.content.map(map),
            pageNumber: dto.pageNumber,
            totalPages: dto.totalPages,
            isLastPage: dto.last
        )
    }

    static func map(_ dto: PageResponseDTO<PharmacyMedicineRequestDTO>) -> PharmacyOrdersPage {
        PharmacyOrdersPage(
            orders: dto.content.map(map),
            pageNumber: dto.pageNumber,
            totalPages: dto.totalPages,
            isLastPage: dto.last
        )
    }


    static func mapToListItem(_ order: PharmacyOrder) -> PharmacyOrderListItem {
        PharmacyOrderListItem(
            id: String(order.id),
            customerName: "pharmacy.orders.customer.fallback".localized(String(order.userId)),
            phoneNumber: "—",
            address: "pharmacy.orders.address.fallback".localized,
            paymentMethod: .cash,
            amount: Int(order.totalPrice.rounded()),
            minutesAgo: Int(Date().timeIntervalSince(order.date) / 60),
            status: mapStatus(order.status)
        )
    }

    private static func mapStatus(_ status: PharmacyOrderAPIStatus) -> PharmacyOrderListStatus {
        switch status {
        case .pending: .new
        case .accepted, .preparing, .outForDelivery: .preparing
        case .delivered: .delivered
        case .cancelled, .unknown: .delivered
        }
    }
}
