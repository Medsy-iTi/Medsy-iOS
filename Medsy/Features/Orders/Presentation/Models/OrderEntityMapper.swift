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
            itemCount: entity.itemCount
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
            productName: entity.productName,
            originalProductName: entity.originalProductName,
            quantity: entity.quantity,
            unitPrice: entity.unitPrice
        )
    }
}

extension OrderFilter {
    var domainStatuses: [OrderStatus]? {
        switch self {
        case .all:       return nil
        case .active:    return [.pending, .confirmed, .preparing, .readyForPickup, .outForDelivery]
        case .completed: return [.delivered]
        case .cancelled: return [.cancelled]
        }
    }

    func matches(_ status: OrderStatus) -> Bool {
        guard let domainStatuses else { return true }
        let acceptedValues = Set(domainStatuses.map(\.rawValue))
        return acceptedValues.contains(status.rawValue)
    }
}
