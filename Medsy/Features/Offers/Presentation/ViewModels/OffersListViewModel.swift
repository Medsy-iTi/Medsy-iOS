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
                pharmacyName: "offers.list.pharmacy.nahda".localized,
                subtitle: "offers.list.subtitle.bestPrice".localized,
                price: 48,
                badgeType: .full,
                isBestOption: true
            ),
            OfferPresentationModel(
                id: "2",
                pharmacyName: "offers.list.pharmacy.shifa".localized,
                subtitle: "offers.list.subtitle.unavailableMeds".localized,
                price: 36,
                badgeType: .partial,
                isBestOption: false
            ),
            OfferPresentationModel(
                id: "3",
                pharmacyName: "offers.list.pharmacy.twoPharmacies".localized,
                subtitle: "offers.list.subtitle.fullCoverage".localized,
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
        String(format: "offers.list.subtitleFormat".localized, totalOffersCount)
    }
}
