//
//  PharmacyDashboard.swift
//  Medsy-Pharmacy
//

import Foundation

enum PharmacyDashboardPeriod: String, CaseIterable, Identifiable, Sendable {
    case lastDay = "LAST_DAY"
    case lastWeek = "LAST_WEEK"
    case lastMonth = "LAST_MONTH"
    case lastYear = "LAST_YEAR"

    var id: String { rawValue }

    var titleKey: String {
        switch self {
        case .lastDay:
            "pharmacy.home.period.last_day"
        case .lastWeek:
            "pharmacy.home.period.last_week"
        case .lastMonth:
            "pharmacy.home.period.last_month"
        case .lastYear:
            "pharmacy.home.period.last_year"
        }
    }
}

struct PharmacyDashboard: Equatable, Sendable {
    let totalRevenue: Double
    let totalOrders: Int
    let requestsReceived: Int
    let offersCreated: Int
    let topSellingProducts: [PharmacyDashboardTopSellingProduct]
    let recentOrders: [PharmacyDashboardRecentOrder]
}

struct PharmacyDashboardTopSellingProduct: Identifiable, Equatable, Sendable {
    let productId: Int
    let productName: String?
    let imageUrl: String?
    let totalQuantitySold: Int
    let totalRevenue: Double

    var id: Int { productId }
}

struct PharmacyDashboardRecentOrder: Identifiable, Equatable, Sendable {
    let id: Int
    let customerId: Int
    let customerName: String?
    let customerNotes: String?
    let deliveryAddress: String?
    let phoneNumber: String?
    let prescriptionUrl: String?
    let pharmacyId: Int
    let pharmacyName: String?
    let pharmacyAddress: String?
    let pharmacyPhone: String?
    let pharmacistId: Int
    let pharmacistName: String?
    let offerId: Int
    let subTotal: Double
    let deliveryFee: Double
    let total: Double
    let deliveryLatitude: Double
    let deliveryLongitude: Double
    let createdAt: Date?
    let items: [PharmacyDashboardRecentOrderItem]
}

struct PharmacyDashboardRecentOrderItem: Identifiable, Equatable, Sendable {
    let id: Int
    let productId: Int
    let productName: String?
    let imageUrl: String?
    let quantity: Int
    let unitPrice: Double
    let totalPrice: Double
}
