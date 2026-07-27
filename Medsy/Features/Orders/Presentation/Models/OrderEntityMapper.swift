//
//  OrderEntityMapper.swift
//  Medsy
//
//  Created by Ahmed Elkady on 21/07/2026.
//

import Foundation

enum OrderEntityMapper {
    static func map(_ entity: OrderEntity) -> OrderPresentationModel {
        OrderPresentationModel(
            id: entity.id,
            orderNumber: entity.orderNumber,
            pharmacyName: entity.pharmacyName,
            status: OrderStatusPresentation(rawValue: entity.status.rawValue),
            fulfillmentType: entity.fulfillmentType,
            date: entity.date,
            totalPrice: entity.totalPrice,
            itemCount: entity.itemCount,
            itemImageURLs: entity.itemImageURLs
        )
    }

    static func mapDetail(_ entity: OrderDetailEntity) -> OrderDetailPresentationModel {
        OrderDetailPresentationModel(
            id: entity.id,
            orderNumber: entity.orderNumber,
            pharmacyName: entity.pharmacyName,
            pharmacyId: entity.pharmacyId,
            status: OrderStatusPresentation(rawValue: entity.status.rawValue),
            fulfillmentType: entity.fulfillmentType,
            date: entity.date,
            items: entity.items.map(mapItem),
            itemsSubtotal: entity.itemsSubtotal,
            deliveryFee: entity.deliveryFee,
            totalPrice: entity.totalPrice
        )
    }

    private static func mapItem(_ entity: OrderDetailItemEntity) -> OrderDetailItemModel {
        OrderDetailItemModel(
            id: entity.id,
            productId: entity.productId,
            productName: entity.productName,
            originalProductName: entity.originalProductName,
            quantity: entity.quantity,
            unitPrice: entity.unitPrice,
            imageURL: entity.imageURL
        )
    }
}

extension ActiveOrderFilters {
    func toDomainFilter() -> OrdersFilter {
        let range = resolvedDateRange()
        return OrdersFilter(
            statuses: statusFilter.domainStatuses,
            fulfillmentType: fulfillmentType,
            dateFrom: range.from,
            dateTo: range.to
        )
    }

    func matches(_ order: OrderPresentationModel) -> Bool {
        if let requiredFulfillment = fulfillmentType, order.fulfillmentType != requiredFulfillment {
            return false
        }
        let range = resolvedDateRange()
        if let from = range.from, order.date < from { return false }
        if let to = range.to, order.date > to { return false }
        return statusFilter.matches(order.status)
    }
}

private extension OrderFilter {
    var domainStatuses: [OrderStatus]? {
        switch self {
        case .all:       return nil
        case .active:    return [.pending, .confirmed, .preparing, .readyForPickup, .outForDelivery]
        case .completed: return [.delivered]
        case .cancelled: return [.cancelled]
        }
    }

    func matches(_ status: OrderStatusPresentation) -> Bool {
        guard let domainStatuses else { return true }
        let acceptedValues = Set(domainStatuses.map(\.rawValue))
        return acceptedValues.contains(status.rawValue)
    }
}

private extension OrderStatusPresentation {
    var rawValue: String {
        switch self {
        case .pending:         return "PENDING"
        case .confirmed:       return "CONFIRMED"
        case .preparing:       return "PREPARING"
        case .readyForPickup:  return "READY_FOR_PICKUP"
        case .outForDelivery:  return "OUT_FOR_DELIVERY"
        case .delivered:       return "DELIVERED"
        case .cancelled:       return "CANCELLED"
        case .unknown(let r):  return r
        }
    }
}
