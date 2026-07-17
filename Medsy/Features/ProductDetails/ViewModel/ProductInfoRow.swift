//
//  ProductInfoRow.swift
//  Medsy
//
//  Created by Shahudaa on 15/07/2026.
//

import Foundation

struct ProductInfoRow: Identifiable {
    let id = UUID()
    let icon: String
    let label: String
    let value: String
    var valueColor: MedsyRowTint = .primary
}

enum MedsyRowTint {
    case primary
    case danger
}

struct ProductDetail: Identifiable {
    let id: String
    let images: [String]
    let title: String
    let subtitle: String
    let price: Double
    let currencyKey: String
    let requiresPharmacistReview: Bool
    let descriptionText: String
    let infoRows: [ProductInfoRow]
}

extension ProductDetail {

    static let sample = ProductDetail(
        id: "panadol-extra",
        images: ["panadol_1", "panadol_2", "panadol_3", "panadol_4"],
        title: "بانادول اكسترا",
        subtitle: "500 مجم - 24 قرص",
        price: 68,
        currencyKey: "currency.egp",
        requiresPharmacistReview: true,
        descriptionText: "مسكن للألم وخافض للحرارة.\nتحديد الجرعة ومدة الاستخدام يتم بواسطة الصيدلي أو الطبيب حسب حالتك الصحية.",
        infoRows: [
            ProductInfoRow(icon: "flask", label: "product.manufacturer", value: "جلاكسو سميث كلاين"),
            ProductInfoRow(icon: "pencil.and.outline", label: "product.type", value: "مسكن وخافض حرارة"),
            ProductInfoRow(icon: "shippingbox", label: "product.category", value: "مسكنات وأدوية الألم"),
            ProductInfoRow(icon: "lock", label: "product.dispense_method", value: "يصرف بعد مراجعة الصيدلي", valueColor: .danger)
        ]
    )
}
