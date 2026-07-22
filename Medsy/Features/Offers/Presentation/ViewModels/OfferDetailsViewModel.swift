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
        self.offerDetail = OfferDetailPresentationModel(
            id: offer?.id ?? "1",
            pharmacyName: offer?.pharmacyName ?? "صيدلية النهضة",
            managerName: "محمد أحمد (المدير)",
            medicines: [
                OfferMedicineItem(
                    id: "m1",
                    name: "بانادول اكسترا",
                    dosage: "20 قرص",
                    price: 24,
                    isAvailable: true,
                    imageName: "pill.fill"
                ),
                OfferMedicineItem(
                    id: "m2",
                    name: "أموكسيسيلين 500 مجم",
                    dosage: "16 كبسولة",
                    price: 12,
                    isAvailable: true,
                    imageName: "cross.vial.fill"
                ),
                OfferMedicineItem(
                    id: "m3",
                    name: "بروفين 400 مجم",
                    dosage: "10 أقراص",
                    price: 8,
                    isAvailable: true,
                    imageName: "pills.fill"
                ),
                OfferMedicineItem(
                    id: "m4",
                    name: "فيتامين سي 1000 مجم",
                    dosage: "10 أقراص",
                    price: 4,
                    isAvailable: true,
                    imageName: "leaf.fill"
                )
            ],
            pharmacistComment: "مرحباً، جميع الأدوية متوفرة وجاهزة للتجهيز. يرجى الالتزام بالجرعات الموضحة. نتمنى لك الشفاء العاجل 🌿",
            totalPrice: offer?.price ?? 48
        )
    }

    func selectOffer() {
    }
}
