//
//  PharmacyHomeModels.swift
//  Medsy-Pharmacy
//

import SwiftUI

enum PharmacyHomeMetricValue {
    case count(Int)
    case revenue(Double)
}

struct PharmacyHomeMetric: Identifiable {
    let titleKey: String
    let value: PharmacyHomeMetricValue
    let icon: String
    let tint: Color

    var id: String { titleKey }
}

struct PharmacyHomeTopProduct: Identifiable {
    let id: Int
    let name: String
    let imageUrl: URL?
    let quantitySold: Int
    let revenue: Double

    init(product: PharmacyDashboardTopSellingProduct) {
        id = product.productId
        name = product.productName ?? "pharmacy.home.product_unavailable".localized
        imageUrl = product.imageUrl.flatMap(URL.init(string:))
        quantitySold = product.totalQuantitySold
        revenue = product.totalRevenue
    }
}

struct PharmacyHomeRecentOrder: Identifiable {
    let id: Int
    let customerName: String
    let address: String
    let createdAt: Date?
    let total: Double

    init(order: PharmacyDashboardRecentOrder) {
        id = order.id
        customerName = order.customerName
            ?? "pharmacy.orders.customer.fallback".localized(String(order.customerId))
        address = order.deliveryAddress
            ?? "pharmacy.orders.address.fallback".localized
        createdAt = order.createdAt
        total = order.total
    }
}
