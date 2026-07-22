//  OffersListViewModel.swift
//  Medsy
//
//  Created by Antoneos Philip on 22/07/2026.

import Foundation
import Observation

@MainActor
@Observable
final class OffersListViewModel {
    var offers: [OfferPresentationModel] = []

    init() {
        loadOffers()
    }

    func loadOffers() {
        offers = [
            OfferPresentationModel(
                id: "1",
                pharmacyName: "صيدلية النهضة",
                subtitle: "أفضل سعر",
                price: 48,
                badgeType: .full,
                isBestOption: true
            ),
            OfferPresentationModel(
                id: "2",
                pharmacyName: "صيدلية الشفاء",
                subtitle: "يحتوي على أدوية غير متوفرة",
                price: 36,
                badgeType: .partial,
                isBestOption: false
            ),
            OfferPresentationModel(
                id: "3",
                pharmacyName: "عرض من صيدليتين",
                subtitle: "تغطية كاملة للطلب",
                price: 46,
                badgeType: .combined,
                isBestOption: false
            )
        ]
    }

    var totalOffersCount: Int {
        offers.count
    }

    var subtitleText: String {
        "\(totalOffersCount) عروض متاحة لطلبك"
    }
}
