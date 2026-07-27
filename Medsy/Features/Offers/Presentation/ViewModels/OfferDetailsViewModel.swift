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
    private(set) var isConfirming = false
    private(set) var confirmErrorMessage: String?
    private(set) var isConfirmed = false

    let requestId: Int?
    private let confirmOfferUseCase: ConfirmOfferUseCaseProtocol?
    private let statusStore: UserDefaultsStatusStoreProtocol?

    init(
        offer: OfferPresentationModel? = nil,
        offerResult: OfferResult? = nil,
        requestId: Int? = nil,
        confirmOfferUseCase: ConfirmOfferUseCaseProtocol? = nil,
        statusStore: UserDefaultsStatusStoreProtocol? = nil
    ) {
        self.requestId = requestId
        // OLD:
        // self.confirmOfferUseCase = confirmOfferUseCase
        // self.statusStore = statusStore

        self.confirmOfferUseCase = confirmOfferUseCase ?? DIContainer.shared.resolve(ConfirmOfferUseCaseProtocol.self)
        self.statusStore = statusStore ?? DIContainer.shared.resolve(UserDefaultsStatusStoreProtocol.self)

        if let offerResult {
            let items = offerResult.items.map { item in
                OfferMedicineItem(
                    id: "\(item.requestItemId)",
                    requestItemId: item.requestItemId,
                    name: item.productName,
                    dosage: "",
                    price: item.unitPrice,
                    isAvailable: item.isAvailable,
                    isAlternative: item.isAlternative,
                    imageName: item.isAlternative ? "pills.fill" : "pill.fill",
                    imageUrl: item.imageUrl
                )
            }
            self.offerDetail = OfferDetailPresentationModel(
                id: "\(requestId ?? 1)",
                pharmacyName: "offers.list.pharmacy.nahda".localized,
                managerName: "محمد أحمد " + "offers.details.managerSuffix".localized,
                medicines: items,
                pharmacistComment: "offers.details.defaultComment".localized,
                totalPrice: offerResult.totalPrice,
                prescriptionUrl: offerResult.prescriptionUrl
            )
        } else {
            self.offerDetail = OfferDetailPresentationModel(
                id: offer?.id ?? "1",
                pharmacyName: offer?.pharmacyName ?? "offers.list.pharmacy.nahda".localized,
                managerName: "محمد أحمد " + "offers.details.managerSuffix".localized,
                medicines: [],
                pharmacistComment: "offers.details.defaultComment".localized,
                totalPrice: Double(offer?.price ?? 0),
                prescriptionUrl: nil
            )
        }
    }

    func toggleItemSelection(id: String) {
        guard let index = offerDetail.medicines.firstIndex(where: { $0.id == id }) else { return }
        guard offerDetail.medicines[index].isAvailable else { return }

        var updatedMedicines = offerDetail.medicines
        updatedMedicines[index].isSelected.toggle()

        let newTotal = updatedMedicines
            .filter { $0.isAvailable && $0.isSelected }
            .reduce(0.0) { $0 + $1.price }

        offerDetail = OfferDetailPresentationModel(
            id: offerDetail.id,
            pharmacyName: offerDetail.pharmacyName,
            managerName: offerDetail.managerName,
            medicines: updatedMedicines,
            pharmacistComment: offerDetail.pharmacistComment,
            totalPrice: newTotal,
            prescriptionUrl: offerDetail.prescriptionUrl
        )
    }

    func selectOffer() async -> Bool {
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

        // OLD:
        // let itemIds = offerDetail.medicines.filter(\.isAvailable).map(\.requestItemId)

        let selectedItemIds = offerDetail.medicines
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

