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
        let medicines = (offerDetail?.medicines ?? []).filter { $0.isAvailable && $0.isSelected }
        let subtotal = medicines.reduce(0.0) { $0 + $1.price }
        let deliveryFee = 0.0
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

    private(set) var confirmOfferResult: ConfirmOfferResult?

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

        let selectedMedicines = orderReview.medicines
            .filter { $0.isAvailable && $0.isSelected }
        let selections = selectedMedicines.compactMap { medicine -> ConfirmOfferSelection? in
            guard let productId = medicine.productId else { return nil }
            return ConfirmOfferSelection(
                requestItemId: medicine.requestItemId,
                productId: productId
            )
        }

        guard selections.count == selectedMedicines.count else {
            confirmErrorMessage = "offers.error.missing_selected_product".localized
            return false
        }

        do {
            let result = try await confirmOfferUseCase.execute(requestId: requestId, selections: selections)
            self.confirmOfferResult = result
            statusStore?.clearPendingRequestId(requestId) // Clear this specific request ID from UserDefaults!
            isConfirmed = true
            return true
        } catch {
            confirmErrorMessage = error.localizedDescription
            return false
        }
    }
}
