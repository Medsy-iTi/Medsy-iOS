//  OfferDetailsViewModel.swift
//  Medsy
//
//  Created by Antoneos Philip on 22/07/2026.

import Foundation
import Observation

@MainActor
@Observable
final class OfferDetailsViewModel {
    var offerDetail: OfferDetailPresentationModel

    init(offer: OfferPresentationModel? = nil) {
        let defaultPharmacyName = "offers.list.pharmacy.nahda".localized
        let managerSuffix = "offers.details.managerSuffix".localized
        let defaultManagerName = "محمد أحمد" + managerSuffix

        self.offerDetail = OfferDetailPresentationModel(
            id: offer?.id ?? "1",
            pharmacyName: offer?.pharmacyName ?? defaultPharmacyName,
            managerName: defaultManagerName,
            medicines: [
                OfferMedicineItem(
                    id: "m1",
                    name: "offers.details.med.panadol".localized,
                    dosage: "offers.details.dosage.panadol".localized,
                    price: 24,
                    isAvailable: true,
                    imageName: "pill.fill"
                ),
                OfferMedicineItem(
                    id: "m2",
                    name: "offers.details.med.amoxicillin".localized,
                    dosage: "offers.details.dosage.amoxicillin".localized,
                    price: 12,
                    isAvailable: true,
                    imageName: "cross.vial.fill"
                ),
                OfferMedicineItem(
                    id: "m3",
                    name: "offers.details.med.brufen".localized,
                    dosage: "offers.details.dosage.brufen".localized,
                    price: 8,
                    isAvailable: true,
                    imageName: "pills.fill"
                ),
                OfferMedicineItem(
                    id: "m4",
                    name: "offers.details.med.vitaminc".localized,
                    dosage: "offers.details.dosage.vitaminc".localized,
                    price: 4,
                    isAvailable: true,
                    imageName: "leaf.fill"
                )
            ],
            pharmacistComment: "offers.details.defaultComment".localized,
            totalPrice: offer?.price ?? 48
        )
    }

    func selectOffer() {
    }
}
