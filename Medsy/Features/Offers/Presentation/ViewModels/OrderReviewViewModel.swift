//  OrderReviewViewModel.swift
//  Medsy
//
//  Created by Antoneos Philip on 22/07/2026.

import Foundation
import Observation

@MainActor
@Observable
final class OrderReviewViewModel {
    var orderReview: OrderReviewPresentationModel

    init(offerDetail: OfferDetailPresentationModel? = nil) {
        let pharmacyName = offerDetail?.pharmacyName ?? "offers.list.pharmacy.nahda".localized
        let managerSuffix = "offers.details.managerSuffix".localized
        let managerName = offerDetail?.managerName ?? ("محمد أحمد" + managerSuffix)
        let medicines = offerDetail?.medicines ?? [
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
        ]
        let subtotal = offerDetail?.totalPrice ?? 48
        let deliveryFee = 20
        let total = subtotal + deliveryFee

        self.orderReview = OrderReviewPresentationModel(
            id: offerDetail?.id ?? "1",
            pharmacyName: pharmacyName,
            managerName: managerName,
            medicines: medicines,
            deliveryAddress: "orderReview.address.text".localized,
            deliveryFee: deliveryFee,
            medicinesSubtotal: subtotal,
            totalPrice: total
        )
    }

    func confirmOrder() {
    }
}
