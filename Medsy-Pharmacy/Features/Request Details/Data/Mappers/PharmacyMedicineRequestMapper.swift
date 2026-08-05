//
//  PharmacyMedicineRequestMapper.swift
//  Medsy-Pharmacy
//
//  Created by Antoneos Philip on 25/07/2026.
//

import Foundation

enum PharmacyMedicineRequestMapper {
    private static let isoFormatter: ISO8601DateFormatter = {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        return formatter
    }()

    private static let fallbackFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
        formatter.calendar = Calendar(identifier: .gregorian)
        formatter.timeZone = TimeZone(identifier: "UTC")
        return formatter
    }()

    static func map(_ dto: PharmacyMedicineRequestDTO) -> PharmacyMedicineRequestEntity {
        let parsedDate: Date? = {
            guard let dateStr = dto.createdAt else { return nil }
            if let date = isoFormatter.date(from: dateStr) {
                return date
            }
            let trimmed = String(dateStr.prefix(19))
            return fallbackFormatter.date(from: trimmed)
        }()

        let items = (dto.items ?? []).map { itemDTO in
            PharmacyMedicineRequestItemEntity(
                id: itemDTO.id,
                productId: itemDTO.productId,
                imageUrl: itemDTO.imageUrl,
                productName: itemDTO.productName ?? "pharmacy.request.product_label".localized(String(itemDTO.productId)),
                quantity: itemDTO.quantity,
                unitPrice: itemDTO.unitPrice ?? 0.0,
                form: itemDTO.form,
                strength: itemDTO.strength,
                packSize: itemDTO.packSize
            )
        }

        return PharmacyMedicineRequestEntity(
            id: dto.id,
            customerId: dto.customerId,
            customerName: dto.customerName,
            customerPhone: dto.customerPhone,
            deliveryLatitude: dto.deliveryLatitude ?? 0.0,
            deliveryLongitude: dto.deliveryLongitude ?? 0.0,
            deliveryAddress: dto.deliveryAddress ?? "pharmacy.orders.address.fallback".localized,
            status: PharmacyOrderAPIStatus(rawValue: dto.status),
            createdAt: parsedDate,
            items: items,
            prescriptionUrl: dto.prescriptionUrl,
            notes: dto.notes
        )
    }

    static func mapToPresentationModel(_ entity: PharmacyMedicineRequestEntity) -> PharmacyRequestDetailsModel {
        let presentationItems = entity.items.map { item in
            PharmacyOrderItem(
                id: String(item.id),
                requestItemId: item.id,
                productId: item.productId,
                name: item.productName,
                spec: "pharmacy.orders.item_pieces".localized(String(item.quantity)),
                quantity: item.quantity,
                price: item.unitPrice,
                imageName: nil,
                imageUrl: makeFullImageUrl(item.imageUrl),
                isAvailable: true,
                selectedOfferProductId: item.productId,
                form: item.form,
                strength: item.strength,
                packSize: item.packSize
            )
        }

        return PharmacyRequestDetailsModel(
            id: String(entity.id),
            statusTitle: mapStatusTitle(entity.status),
            customer: PharmacyCustomerInfo(
                name: entity.customerName ?? "pharmacy.request.customer_id_label".localized(String(entity.customerId ?? 0)),
                phone: entity.customerPhone ?? "—",
                address: entity.deliveryAddress
            ),
            items: presentationItems,
            deliveryFee: 0.0,
            notes: entity.notes ?? "",
            prescriptionImageUrl: makeFullImageUrl(entity.prescriptionUrl),
            deliveryLatitude: entity.deliveryLatitude,
            deliveryLongitude: entity.deliveryLongitude,
            createdAt: entity.createdAt
        )
    }

    private static func makeFullImageUrl(_ urlString: String?) -> String? {
        guard let urlString = urlString, !urlString.isEmpty else { return nil }
        if urlString.hasPrefix("http") { return urlString }
        let rootUrl = PharmacyConfiguration.apiBaseURL
        let path = urlString.hasPrefix("/") ? String(urlString.dropFirst()) : urlString
        return rootUrl + path
    }


    private static func mapStatusTitle(_ status: PharmacyOrderAPIStatus) -> String {
        switch status {
        case .pending: return "pharmacy.home.order_new".localized
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
