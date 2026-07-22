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

    static func map(_ dto: PageResponseDTO<PharmacyOrderDTO>) -> PharmacyOrdersPage {
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
