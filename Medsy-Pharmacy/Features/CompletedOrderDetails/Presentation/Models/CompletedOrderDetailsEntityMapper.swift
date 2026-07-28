//
//  CompletedOrderEntityMapper.swift
//  Medsy
//

import Foundation

enum CompletedOrderDetailsEntityMapper {
    static func map(_ entity: CompletedOrderDetailsEntity) -> CompletedOrderDetailPresentationModel {
        CompletedOrderDetailPresentationModel(
            id: entity.id,
            orderNumber: entity.id,
            customerName: entity.customerName,
            pharmacyId: entity.pharmacyId,
            pharmacyName: entity.pharmacyName,
            pharmacyAddress: entity.pharmacyAddress,
            pharmacyPhone: entity.pharmacyPhone,
            pharmacistName: entity.pharmacistName,
            createdAt: entity.createdAt,
            items: entity.items.map(mapItem),
            subTotal: entity.subTotal,
            deliveryFee: entity.deliveryFee,
            total: entity.total,
            hasDelivery: entity.deliveryLatitude != nil || entity.deliveryLongitude != nil
        )
    }

    private static func mapItem(_ entity: CompletedOrderDetailsItemEntity) -> CompletedOrderItemPresentationModel {
        CompletedOrderItemPresentationModel(
            id: entity.id,
            productId: entity.productId,
            productName: entity.productName,
            imageUrl: entity.imageUrl,
            quantity: entity.quantity,
            unitPrice: entity.unitPrice,
            totalPrice: entity.totalPrice
        )
    }
}
