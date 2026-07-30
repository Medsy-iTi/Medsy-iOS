//
//  CompletedOrderDetailsEntityMapper.swift
//  Medsy
//

import Foundation

enum CompletedOrderDetailsEntityMapper {
    static func map(_ entity: CompletedOrderDetailsEntity) -> CompletedOrderDetailPresentationModel {
        CompletedOrderDetailPresentationModel(
            id: entity.id,
            orderNumber: entity.id,
            customerName: entity.customerName,
            customerNotes: entity.customerNotes,
            pharmacistNotes: entity.pharmacistNotes,
            deliveryAddress: entity.deliveryAddress,
            customerPhone: entity.phoneNumber,
            prescriptionImage: entity.prescriptionImage,
            pharmacistName: entity.pharmacistName,
            pharmacistPhone: entity.pharmacistPhone,
            createdAt: entity.createdAt,
            items: entity.items.map(mapItem),
            subTotal: entity.subTotal,
            deliveryFee: entity.deliveryFee,
            total: entity.total,
            hasDelivery: true,
            deliveryLatitude: entity.deliveryLatitude,
            deliveryLongitude: entity.deliveryLongitude
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
