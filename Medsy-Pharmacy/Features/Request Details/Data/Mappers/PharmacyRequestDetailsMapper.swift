//  PharmacyRequestDetailsMapper.swift
//  Medsy-Pharmacy
//
//  Created by Antoneos Philip on 23/07/2026.
//

import Foundation

enum PharmacyRequestDetailsMapper {
    private static let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        formatter.calendar = Calendar(identifier: .gregorian)
        formatter.timeZone = TimeZone(identifier: "UTC")
        return formatter
    }()

    static func map(_ dto: PharmacyRequestDetailsDTO) -> PharmacyRequestDetailsEntity {
        PharmacyRequestDetailsEntity(
            id: dto.id,
            userId: dto.userId,
            pharmacyId: dto.pharmacyId,
            pharmacistId: dto.pharmacistId,
            offerId: dto.offerId,
            totalPrice: dto.totalPrice,
            deliveryCoordinate: (dto.deliveryLatitude, dto.deliveryLongitude),
            status: PharmacyOrderAPIStatus(rawValue: dto.status),
            date: dateFormatter.date(from: dto.date) ?? Date(),
            items: dto.items.map {
                PharmacyRequestDetailsItemEntity(
                    id: $0.id,
                    productId: $0.productId,
                    quantity: $0.quantity,
                    unitPrice: $0.unitPrice
                )
            }
        )
    }

    static func mapToPresentationModel(_ entity: PharmacyRequestDetailsEntity) -> PharmacyRequestDetailsModel {
        let presentationItems = entity.items.map { item in
            PharmacyOrderItem(
                id: String(item.id),
                name: "pharmacy.request.product_label".localized(String(item.productId)),
                spec: "pharmacy.orders.item_pieces".localized(String(item.quantity)),
                quantity: item.quantity,
                price: item.unitPrice,
                imageName: nil
            )
        }

        return PharmacyRequestDetailsModel(
            id: String(entity.id),
            statusTitle: mapStatusTitle(entity.status),
            customer: PharmacyCustomerInfo(
                name: "pharmacy.request.customer_id_label".localized(String(entity.userId)),
                phone: "01000000000",
                address: "pharmacy.request.address_format".localized(String(entity.deliveryCoordinate.latitude), String(entity.deliveryCoordinate.longitude))
            ),
            items: presentationItems,
            deliveryFee: 15.0,
            notes: "pharmacy.request.customer_notes_default".localized
        )
    }

    private static func mapStatusTitle(_ status: PharmacyOrderAPIStatus) -> String {
        switch status {
        case .pending, .searching: return "pharmacy.home.order_new".localized
        case .accepted: return "pharmacy.home.order_preparing".localized
        case .preparing: return "pharmacy.home.order_preparing".localized
        case .outForDelivery: return "pharmacy.home.order_preparing".localized
        case .delivered: return "pharmacy.home.order_delivered".localized
        case .completed: return "pharmacy.orders.status.completed".localized
        case .expired: return "pharmacy.orders.status.expired".localized
        case .cancelled: return "pharmacy.home.order_delivered".localized
        case .unknown(let val): return val
        }
    }
}
