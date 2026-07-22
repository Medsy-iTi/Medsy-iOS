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
                name: "منتج #\(item.productId)",
                spec: "\(item.quantity) قطعة",
                quantity: item.quantity,
                price: item.unitPrice,
                imageName: nil
            )
        }

        return PharmacyRequestDetailsModel(
            id: String(entity.id),
            statusTitle: mapStatusTitle(entity.status),
            customer: PharmacyCustomerInfo(
                name: "عميل #\(entity.userId)",
                phone: "01000000000",
                address: "الموقع: (\(entity.deliveryCoordinate.latitude), \(entity.deliveryCoordinate.longitude))"
            ),
            items: presentationItems,
            deliveryFee: 15.0,
            notes: "طلب من العميل"
        )
    }

    private static func mapStatusTitle(_ status: PharmacyOrderAPIStatus) -> String {
        switch status {
        case .pending: return "جديد"
        case .accepted: return "مقبول"
        case .preparing: return "قيد التحضير"
        case .outForDelivery: return "جاري التوصيل"
        case .delivered: return "تم التوصيل"
        case .cancelled: return "ملغي"
        case .unknown(let val): return val
        }
    }
}
