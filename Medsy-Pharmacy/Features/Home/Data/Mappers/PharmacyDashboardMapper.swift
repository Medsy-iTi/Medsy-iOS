//
//  PharmacyDashboardMapper.swift
//  Medsy-Pharmacy
//

import Foundation

enum PharmacyDashboardMapper {
    private static let dateOnlyFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.calendar = Calendar(identifier: .gregorian)
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter
    }()

    private static let fractionalISOFormatter: ISO8601DateFormatter = {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        return formatter
    }()

    private static let isoFormatter = ISO8601DateFormatter()

    static func map(_ dto: PharmacyDashboardDTO) -> PharmacyDashboard {
        PharmacyDashboard(
            totalRevenue: dto.totalRevenue,
            totalOrders: dto.totalOrders,
            requestsReceived: dto.requestsReceived,
            offersCreated: dto.offersCreated,
            topSellingProducts: dto.topSellingProducts.map(map),
            recentOrders: dto.recentOrders.map(map)
        )
    }

    static func map(_ dto: PharmacyDashboardTopSellingProductDTO) -> PharmacyDashboardTopSellingProduct {
        PharmacyDashboardTopSellingProduct(
            productId: dto.productId,
            productName: nonEmpty(dto.productName),
            imageUrl: normalizedImageURL(dto.imageUrl),
            totalQuantitySold: dto.totalQuantitySold,
            totalRevenue: dto.totalRevenue
        )
    }

    static func map(_ dto: PharmacyDashboardRecentOrderDTO) -> PharmacyDashboardRecentOrder {
        PharmacyDashboardRecentOrder(
            id: dto.id,
            customerId: dto.customerId,
            customerName: nonEmpty(dto.customerName),
            customerNotes: nonEmpty(dto.customerNotes),
            deliveryAddress: nonEmpty(dto.deliveryAddress),
            phoneNumber: nonEmpty(dto.phoneNumber),
            prescriptionUrl: normalizedImageURL(dto.prescriptionUrl),
            pharmacyId: dto.pharmacyId,
            pharmacyName: nonEmpty(dto.pharmacyName),
            pharmacyAddress: nonEmpty(dto.pharmacyAddress),
            pharmacyPhone: nonEmpty(dto.pharmacyPhone),
            pharmacistId: dto.pharmacistId,
            pharmacistName: nonEmpty(dto.pharmacistName),
            offerId: dto.offerId,
            subTotal: dto.subTotal,
            deliveryFee: dto.deliveryFee,
            total: dto.total,
            deliveryLatitude: dto.deliveryLatitude,
            deliveryLongitude: dto.deliveryLongitude,
            createdAt: parseDate(dto.createdAt),
            items: dto.items.map(map)
        )
    }

    static func map(_ dto: PharmacyDashboardRecentOrderItemDTO) -> PharmacyDashboardRecentOrderItem {
        PharmacyDashboardRecentOrderItem(
            id: dto.id,
            productId: dto.productId,
            productName: nonEmpty(dto.productName),
            imageUrl: normalizedImageURL(dto.imageUrl),
            quantity: dto.quantity,
            unitPrice: dto.unitPrice,
            totalPrice: dto.totalPrice
        )
    }

    static func parseDate(_ value: String) -> Date? {
        fractionalISOFormatter.date(from: value)
            ?? isoFormatter.date(from: value)
            ?? dateOnlyFormatter.date(from: value)
    }

    static func normalizedImageURL(_ value: String?) -> String? {
        guard let value = nonEmpty(value) else { return nil }
        if URL(string: value)?.scheme != nil {
            return value
        }
        let path = value.hasPrefix("/") ? String(value.dropFirst()) : value
        return PharmacyConfiguration.imageBaseURL + path
    }

    private static func nonEmpty(_ value: String?) -> String? {
        guard let value = value?.trimmingCharacters(in: .whitespacesAndNewlines),
              !value.isEmpty else {
            return nil
        }
        return value
    }
}
