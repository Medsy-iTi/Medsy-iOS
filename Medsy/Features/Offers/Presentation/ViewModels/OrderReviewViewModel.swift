//
//  OrderReviewViewModel.swift
//  Medsy
//
//  Created by Antoneos Philip on 25/07/2026.
//

import Foundation
import Observation

enum ReceiveMethod: String, Equatable, CaseIterable, Sendable {
    case delivery
    case pickup
}

@MainActor
@Observable
final class OrderReviewViewModel {
    var orderReview: OrderReviewPresentationModel
    private(set) var isConfirming = false
    private(set) var confirmErrorMessage: String?
    private(set) var isConfirmed = false
    private(set) var paymentMethod: String

    let requestId: Int?
    private let confirmOfferUseCase: ConfirmOfferUseCaseProtocol?
    private let offersRemoteDataSource: OffersRemoteDataSourceProtocol?
    private let statusStore: UserDefaultsStatusStoreProtocol?

    let selectResult: SelectPharmacyResponseDTO?
    var selectedReceiveMethod: ReceiveMethod = .pickup {
        didSet {
            updateTotals()
        }
    }

    var pharmacyId: Int? {
        selectResult?.offers.first?.pharmacyId
    }

    init(
        offerDetail: OfferDetailPresentationModel? = nil,
        requestId: Int? = nil,
        selectResult: SelectPharmacyResponseDTO? = nil,
        paymentMethod: String? = nil,
        deliveryAddress: String? = nil,
        confirmOfferUseCase: ConfirmOfferUseCaseProtocol? = nil,
        offersRemoteDataSource: OffersRemoteDataSourceProtocol? = nil,
        statusStore: UserDefaultsStatusStoreProtocol? = nil
    ) {
        self.requestId = requestId
        self.selectResult = selectResult
        self.paymentMethod = paymentMethod ?? offerDetail?.paymentMethod ?? "CASH"
        self.confirmOfferUseCase = confirmOfferUseCase ?? DIContainer.shared.resolve(ConfirmOfferUseCaseProtocol.self)
        self.offersRemoteDataSource = offersRemoteDataSource ?? DIContainer.shared.resolve(OffersRemoteDataSourceProtocol.self)
        self.statusStore = statusStore ?? DIContainer.shared.resolve(UserDefaultsStatusStoreProtocol.self)

        let pharmacyName = selectResult?.offers.first?.pharmacyName ?? offerDetail?.pharmacyName ?? "offers.list.pharmacy.nahda".localized
        let managerName = ""
        let selectedMedicines = (offerDetail?.medicines ?? []).filter { $0.isAvailable && $0.isSelected }
        let medicines = selectedMedicines.map { med -> OfferMedicineItem in
            var updated = med
            if let selectItem = selectResult?.offers.flatMap(\.items).first(where: { $0.productId == med.productId }) {
                updated.quantity = selectItem.quantity
            }
            if let supplier = selectResult?.offers.first(where: { offer in offer.items.contains(where: { $0.productId == med.productId }) })?.pharmacyName {
                updated.supplierName = supplier
            } else {
                updated.supplierName = pharmacyName
            }
            return updated
        }
        let deliveryFeeAmount = selectResult?.deliveryFees ?? 0.0
        let medicinesCalculatedSubtotal = medicines.reduce(0.0) { $0 + ($1.price * Double($1.quantity)) }
        
        let subtotal: Double
        if let backendTotal = selectResult?.totalPrice, backendTotal > 0 {
            subtotal = max(0, backendTotal - deliveryFeeAmount)
        } else if medicinesCalculatedSubtotal > 0 {
            subtotal = medicinesCalculatedSubtotal
        } else {
            subtotal = 0.0
        }

        let deliveryFee = 0.0
        let total = subtotal + deliveryFee

        let initialAddress = deliveryAddress ?? offerDetail?.deliveryAddress ?? "orderReview.address.text".localized

        self.orderReview = OrderReviewPresentationModel(
            id: offerDetail?.id ?? "1",
            pharmacyName: pharmacyName,
            managerName: managerName,
            medicines: medicines,
            deliveryAddress: initialAddress,
            deliveryFee: deliveryFee,
            medicinesSubtotal: subtotal,
            totalPrice: total
        )
    }

    func loadRequestDetails() async {
        guard let requestId else { return }
        guard let remote = offersRemoteDataSource else { return }
        if let req = try? await remote.fetchRequest(requestId: requestId) {
            if let method = req.paymentMethod, !method.isEmpty {
                self.paymentMethod = method
            }
            let addr = req.deliveryAddress
            if !addr.isEmpty {
                self.orderReview = OrderReviewPresentationModel(
                    id: orderReview.id,
                    pharmacyName: orderReview.pharmacyName,
                    managerName: orderReview.managerName,
                    medicines: orderReview.medicines,
                    deliveryAddress: addr,
                    deliveryFee: orderReview.deliveryFee,
                    medicinesSubtotal: orderReview.medicinesSubtotal,
                    totalPrice: orderReview.totalPrice
                )
            }

            var updatedMeds = orderReview.medicines
            var changed = false
            for idx in updatedMeds.indices {
                if updatedMeds[idx].name == "Medicine" || updatedMeds[idx].name.isEmpty {
                    if let origItem = req.items.first(where: { $0.id == updatedMeds[idx].requestItemId || $0.productId == updatedMeds[idx].productId }) {
                        updatedMeds[idx] = OfferMedicineItem(
                            id: updatedMeds[idx].id,
                            requestItemId: updatedMeds[idx].requestItemId,
                            productId: updatedMeds[idx].productId ?? origItem.productId,
                            name: origItem.productName,
                            dosage: origItem.strength,
                            price: updatedMeds[idx].price,
                            isAvailable: updatedMeds[idx].isAvailable,
                            isAlternative: updatedMeds[idx].isAlternative,
                            imageName: updatedMeds[idx].imageName,
                            imageUrl: origItem.imageUrl ?? updatedMeds[idx].imageUrl,
                            isSelected: updatedMeds[idx].isSelected,
                            quantity: updatedMeds[idx].quantity,
                            supplierName: updatedMeds[idx].supplierName
                        )
                        changed = true
                    }
                }
            }
            if changed {
                self.orderReview = OrderReviewPresentationModel(
                    id: orderReview.id,
                    pharmacyName: orderReview.pharmacyName,
                    managerName: orderReview.managerName,
                    medicines: updatedMeds,
                    deliveryAddress: orderReview.deliveryAddress,
                    deliveryFee: orderReview.deliveryFee,
                    medicinesSubtotal: orderReview.medicinesSubtotal,
                    totalPrice: orderReview.totalPrice
                )
            }
        }
    }

    private func updateTotals() {
        let deliveryFeeAmount = selectResult?.deliveryFees ?? 0.0
        let medicinesCalculatedSubtotal = orderReview.medicines.reduce(0.0) { $0 + ($1.price * Double($1.quantity)) }
        
        let subtotal: Double
        if let backendTotal = selectResult?.totalPrice, backendTotal > 0 {
            subtotal = max(0, backendTotal - deliveryFeeAmount)
        } else if medicinesCalculatedSubtotal > 0 {
            subtotal = medicinesCalculatedSubtotal
        } else {
            subtotal = 0.0
        }

        let deliveryFee = selectedReceiveMethod == .delivery ? deliveryFeeAmount : 0.0
        let total = subtotal + deliveryFee

        self.orderReview = OrderReviewPresentationModel(
            id: orderReview.id,
            pharmacyName: orderReview.pharmacyName,
            managerName: orderReview.managerName,
            medicines: orderReview.medicines,
            deliveryAddress: orderReview.deliveryAddress,
            deliveryFee: deliveryFee,
            medicinesSubtotal: subtotal,
            totalPrice: total
        )
    }

    private(set) var confirmOfferResult: ConfirmOfferResult?

    func confirmOrder() async -> Bool {
        guard !isConfirming && !isConfirmed else { return false }
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

        do {
            let methodStr = selectedReceiveMethod == .delivery ? "DELIVERY" : "PICKUP"
            let result = try await confirmOfferUseCase.confirmOffer(requestId: requestId, fulfillmentMethod: methodStr)
            self.confirmOfferResult = result
            isConfirmed = true
            return true
        } catch {
            confirmErrorMessage = error.localizedDescription
            return false
        }
    }
}
