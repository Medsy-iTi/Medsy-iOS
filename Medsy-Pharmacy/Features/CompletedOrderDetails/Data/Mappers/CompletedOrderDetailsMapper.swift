//
//  CompletedOrderDetailsMapper.swift
//  Medsy
//

import Foundation

enum CompletedOrderDetailsMapper {
    private static let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        formatter.locale = Locale(identifier: "en_US_POSIX")
        return formatter
    }()

    static func mapToEntity(_ dto: CompletedOrderDetailsDTO) -> CompletedOrderDetailsEntity {
        CompletedOrderDetailsEntity(
            id: dto.id,
            customerId: dto.customerId,
            customerName: dto.customerName ?? "",
            customerNotes: dto.customerNotes ?? "",
            pharmacistNotes: dto.pharmacistNotes ?? "",
            deliveryAddress: dto.deliveryAddress ?? "",
            phoneNumber: dto.phoneNumber ?? "",
            prescriptionImage: getFullUrl(dto.prescriptionUrl),
            pharmacistName: dto.pharmacistName ?? "",
            pharmacistPhone: dto.pharmacyPhone ?? "",
            offerId: dto.offerId,
            subTotal: dto.subTotal,
            deliveryFee: dto.deliveryFee,
            total: dto.total,
            deliveryLatitude: dto.deliveryLatitude,
            deliveryLongitude: dto.deliveryLongitude,
            createdAt: date(from: dto.createdAt),
            items: dto.items.map(mapItem)
        )
    }

    private static func mapItem(_ dto: CompletedOrderDetailsItemDTO) -> CompletedOrderDetailsItemEntity {
        CompletedOrderDetailsItemEntity(
            id: dto.id,
            productId: dto.productId,
            productName: dto.productName,
            imageUrl: dto.imageUrl,
            quantity: dto.quantity,
            unitPrice: dto.unitPrice,
            totalPrice: dto.totalPrice
        )
    }

    private static func date(from string: String) -> Date {
        dateFormatter.date(from: string) ?? Date()
    }

    private static func getFullUrl(_ path: String?) -> String? {
        guard let path = path, !path.isEmpty else { return nil }
        if path.hasPrefix("http") { return path }
        let cleanPath = path.hasPrefix("/") ? String(path.dropFirst()) : path
        return PharmacyConfiguration.imageBaseURL + cleanPath
    }
}
