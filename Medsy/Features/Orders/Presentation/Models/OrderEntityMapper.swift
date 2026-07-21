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
            status: OrderStatusPresentation(rawValue: entity.status.rawValue),
            date: entity.date,
            items: entity.items.map(mapItem),
            deliveryFee: entity.deliveryFee,
            totalPrice: entity.totalPrice
        )
    }

    private static func mapItem(_ entity: OrderDetailItemEntity) -> OrderDetailItemModel {
        OrderDetailItemModel(
            id: entity.id,
            productName: entity.productName,
            quantity: entity.quantity,
            unitPrice: entity.unitPrice
        )
    }
}

extension OrderFilter {
    var domainStatuses: [OrderStatus]? {
        switch self {
        case .all:       return nil
        case .active:    return [.pending, .confirmed, .processing, .shipped]
        case .completed: return [.delivered]
        case .cancelled: return [.cancelled, .rejected]
        }
    }
}
