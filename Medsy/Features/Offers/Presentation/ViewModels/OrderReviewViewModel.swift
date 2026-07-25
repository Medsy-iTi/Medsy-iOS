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
    private(set) var isConfirming = false
    private(set) var confirmErrorMessage: String?
    private(set) var isConfirmed = false

    let requestId: Int?
    private let confirmOfferUseCase: ConfirmOfferUseCaseProtocol?
    private let statusStore: UserDefaultsStatusStoreProtocol?

    init(
        offerDetail: OfferDetailPresentationModel? = nil,
        requestId: Int? = nil,
        confirmOfferUseCase: ConfirmOfferUseCaseProtocol? = nil,
        statusStore: UserDefaultsStatusStoreProtocol? = nil
    ) {
        self.requestId = requestId
        self.confirmOfferUseCase = confirmOfferUseCase ?? DIContainer.shared.resolve(ConfirmOfferUseCaseProtocol.self)
        self.statusStore = statusStore ?? DIContainer.shared.resolve(UserDefaultsStatusStoreProtocol.self)

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
        let subtotal = offerDetail?.totalPrice ?? 48.0
        let deliveryFee = 20.0
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

    // OLD:
    // func confirmOrder() {
    // }

    func confirmOrder() async -> Bool {
        guard let requestId else {
            isConfirmed = true
            return true
        }
        guard let confirmOfferUseCase else {
            statusStore?.clearPendingRequestId()
            isConfirmed = true
            return true
        }

        isConfirming = true
        confirmErrorMessage = nil
        defer { isConfirming = false }

        let selectedItemIds = orderReview.medicines
            .filter { $0.isAvailable && $0.isSelected }
            .map(\.requestItemId)

        do {
            _ = try await confirmOfferUseCase.execute(requestId: requestId, selectedRequestItemIds: selectedItemIds)
            statusStore?.clearPendingRequestId()
            isConfirmed = true
            return true
        } catch {
            confirmErrorMessage = error.localizedDescription
            return false
        }
    }
}
