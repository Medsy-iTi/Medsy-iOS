//  PharmacyRequestDetailsViewModel.swift
//  Medsy-Pharmacy
//
//  Created by Antoneos Philip on 23/07/2026.
//

import Foundation
import Observation

@MainActor
@Observable
final class PharmacyRequestDetailsViewModel {
    enum State: Equatable {
        case idle
        case loading
        case loaded
        case failed(String)
    }

    private(set) var state: State = .idle
    var requestModel: PharmacyRequestDetailsModel?
    let requestId: Int
    private let orderStatus: PharmacyOrderAPIStatus

    var isSubmitting: Bool = false
    var isOfferSubmitted: Bool = false
    var showSuccessAlert: Bool = false
    var alertMessage: String? = nil

    private let fetchRequestsUseCase: FetchPharmacyRequestsUseCaseProtocol?
    private let sendOfferUseCase: SendOfferUseCaseProtocol?

    var showBottomBar: Bool {
        true
    }

    var bottomButtonTitle: String {
        switch orderStatus {
        case .pending:
            return isOfferSubmitted ? "pharmacy.orders.status.pending".localized : "pharmacy.orders.action.send_offer".localized
        case .accepted, .preparing, .outForDelivery, .delivered, .completed:
            return "pharmacy.orders.status.completed".localized
        case .cancelled, .expired:
            return "pharmacy.orders.action.expired".localized
        case .unknown(let val):
            return val
        }
    }

    var isBottomButtonDisabled: Bool {
        return isOfferSubmitted || orderStatus != .pending || isSubmitting
    }

    var showSecondaryButtons: Bool {
        return orderStatus == .pending && !isOfferSubmitted
    }

    init(
        requestId: Int,
        fetchRequestsUseCase: FetchPharmacyRequestsUseCaseProtocol? = nil,
        sendOfferUseCase: SendOfferUseCaseProtocol? = nil
    ) {
        self.requestId = requestId
        self.orderStatus = .pending
        self.fetchRequestsUseCase = fetchRequestsUseCase
        self.sendOfferUseCase = sendOfferUseCase
        if PharmacySubmittedOffersStore.shared.contains(requestId) {
            self.isOfferSubmitted = true
        }
    }

    init(
        order: PharmacyOrder,
        fetchRequestsUseCase: FetchPharmacyRequestsUseCaseProtocol? = nil,
        sendOfferUseCase: SendOfferUseCaseProtocol? = nil
    ) {
        self.requestId = order.id
        self.orderStatus = order.status
        self.fetchRequestsUseCase = fetchRequestsUseCase
        self.sendOfferUseCase = sendOfferUseCase
        self.requestModel = PharmacyOrderMapper.mapToDetailsPresentationModel(order)
        self.state = .loaded
        if order.status != .pending || PharmacySubmittedOffersStore.shared.contains(order.id) {
            self.isOfferSubmitted = true
        }
    }

    func loadDetails() async {
        if requestModel != nil {
            return
        }
        state = .loading
        do {
            let useCase = fetchRequestsUseCase ?? PharmacyAppAssembler.shared.container.resolve(FetchPharmacyRequestsUseCaseProtocol.self)
            let entity = try await useCase.execute(requestId: requestId)
            self.requestModel = PharmacyMedicineRequestMapper.mapToPresentationModel(entity)
            self.state = .loaded
        } catch {
            let errMsg = (error as? NetworkError)?.errorDescription ?? error.localizedDescription
            self.state = .failed(errMsg)
        }
    }

    func updateSelectedProductId(for itemId: String, productId: Int) {
        guard var model = requestModel else { return }
        if let idx = model.items.firstIndex(where: { $0.id == itemId }) {
            model.items[idx].selectedOfferProductId = productId
            self.requestModel = model
        }
    }

    func sendOffer() async {
        guard !isSubmitting, !isOfferSubmitted, let model = requestModel else { return }
        isSubmitting = true
        let offerItems = model.items.filter { $0.isAvailable }.map { item in
            (requestItemId: item.requestItemId, productId: item.selectedOfferProductId)
        }
        guard !offerItems.isEmpty else {
            self.alertMessage = "يرجى تحديد صنف واحد على الأقل لتقديم العرض"
            self.showSuccessAlert = true
            isSubmitting = false
            return
        }
        do {
            let useCase = sendOfferUseCase ?? PharmacyAppAssembler.shared.container.resolve(SendOfferUseCaseProtocol.self)
            let success = try await useCase.execute(requestId: requestId, items: offerItems)
            if success {
                PharmacySubmittedOffersStore.shared.insert(self.requestId)
                self.isOfferSubmitted = true
                self.alertMessage = "تم إرسال العرض بنجاح"
                self.showSuccessAlert = true
                if var currentModel = self.requestModel {
                    currentModel = PharmacyRequestDetailsModel(
                        id: currentModel.id,
                        minutesAgo: currentModel.minutesAgo,
                        statusTitle: "pharmacy.orders.status.pending".localized,
                        customer: currentModel.customer,
                        items: currentModel.items,
                        deliveryFee: currentModel.deliveryFee,
                        notes: currentModel.notes,
                        prescriptionImageUrl: currentModel.prescriptionImageUrl
                    )
                    self.requestModel = currentModel
                }
            }
        } catch {
            let errMsg = (error as? NetworkError)?.errorDescription ?? error.localizedDescription
            self.alertMessage = errMsg
            self.showSuccessAlert = true
        }
        isSubmitting = false
    }
}
