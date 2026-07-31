//
//  PharmacyDashboardDTO.swift
//  Medsy-Pharmacy
//

import Foundation

struct PharmacyDashboardEnvelopeDTO: Decodable {
    let success: Bool
    let message: String
    let data: PharmacyDashboardDTO?
}

struct PharmacyDashboardDTO: Decodable {
    let totalRevenue: Double
    let totalOrders: Int
    let requestsReceived: Int
    let offersCreated: Int
    let topSellingProducts: [PharmacyDashboardTopSellingProductDTO]
    let recentOrders: [PharmacyDashboardRecentOrderDTO]
}

struct PharmacyDashboardTopSellingProductDTO: Decodable {
    let productId: Int
    let productName: String?
    let imageUrl: String?
    let totalQuantitySold: Int
    let totalRevenue: Double
}

struct PharmacyDashboardRecentOrderDTO: Decodable {
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
    let createdAt: String
    let items: [PharmacyDashboardRecentOrderItemDTO]
}

struct PharmacyDashboardRecentOrderItemDTO: Decodable {
    let id: Int
    let productId: Int
    let productName: String?
    let imageUrl: String?
    let quantity: Int
    let unitPrice: Double
    let totalPrice: Double
}
