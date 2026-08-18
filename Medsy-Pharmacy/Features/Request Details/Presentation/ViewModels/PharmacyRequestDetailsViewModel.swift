// PharmacyRequestDetailsViewModel.swift

import Foundation
import Observation
import UIKit

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

    private(set) var requestStatus: RequestStatus = .open
    private(set) var assignmentStatus: AssignmentStatus = .canOffer

    var isSubmitting: Bool = false
    var isOfferSubmitted: Bool = false
    var showSuccessAlert: Bool = false
    var alertMessage: String? = nil

    private let fetchRequestsUseCase: FetchPharmacyRequestsUseCaseProtocol?
    private let sendOfferUseCase: SendOfferUseCaseProtocol?
    private let prescriptionImageDataSource: PrescriptionImageDataSource?

    private(set) var prescriptionUIImage: UIImage? = nil

    var showBottomBar: Bool {
        true
    }

    var bottomButtonTitle: String {
        if requestStatus == .completed {
            return "pharmacy.orders.status.completed".localized
        }
        if requestStatus == .expired {
            return "pharmacy.orders.action.expired".localized
        }
        
        switch assignmentStatus {
        case .offered:
            return "pharmacy.orders.status.pending".localized
        case .canOffer:
            return "pharmacy.orders.action.send_offer".localized
        case .cannotOffer:
            return "pharmacy.orders.action.expired".localized
        }
    }

    var isBottomButtonDisabled: Bool {
        if isSubmitting { return true }
        return requestStatus != .open || assignmentStatus != .canOffer
    }

    var showSecondaryButtons: Bool {
        return requestStatus == .open && assignmentStatus == .canOffer
    }

    init(
        requestId: Int,
        fetchRequestsUseCase: FetchPharmacyRequestsUseCaseProtocol? = nil,
        sendOfferUseCase: SendOfferUseCaseProtocol? = nil,
        prescriptionImageDataSource: PrescriptionImageDataSource? = nil
    ) {
        self.requestId = requestId
        self.orderStatus = .pending
        self.fetchRequestsUseCase = fetchRequestsUseCase
        self.sendOfferUseCase = sendOfferUseCase
        self.prescriptionImageDataSource = prescriptionImageDataSource
        if PharmacySubmittedOffersStore.shared.contains(requestId) {
            self.isOfferSubmitted = true
            self.assignmentStatus = .offered
        } else {
            self.assignmentStatus = .canOffer
        }
        self.requestStatus = .open
    }

    init(
        order: PharmacyOrder,
        fetchRequestsUseCase: FetchPharmacyRequestsUseCaseProtocol? = nil,
        sendOfferUseCase: SendOfferUseCaseProtocol? = nil,
        prescriptionImageDataSource: PrescriptionImageDataSource? = nil
    ) {
        self.requestId = order.id
        self.orderStatus = order.status
        self.fetchRequestsUseCase = fetchRequestsUseCase
        self.sendOfferUseCase = sendOfferUseCase
        self.prescriptionImageDataSource = prescriptionImageDataSource
        self.requestModel = PharmacyOrderMapper.mapToDetailsPresentationModel(order)
        self.state = .loaded
        
        switch order.status {
        case .completed:
            self.requestStatus = .completed
        case .expired:
            self.requestStatus = .expired
        case .searching, .pending:
            self.requestStatus = .open
        default:
            self.requestStatus = .open
        }
        
        if let rawAssignment = order.assignmentStatus?.uppercased() {
            if rawAssignment == "OFFER_CREATED" || rawAssignment == "OFFER_MADE" || rawAssignment == "SUBMITTED" || rawAssignment == "OFFERED" {
                self.assignmentStatus = .offered
            } else if rawAssignment == "PENDING" {
                self.assignmentStatus = .canOffer
            } else {
                self.assignmentStatus = .cannotOffer
            }
        } else {
            if PharmacySubmittedOffersStore.shared.contains(order.id) {
                self.assignmentStatus = .offered
            } else {
                self.assignmentStatus = .canOffer
            }
        }
        
        if self.requestStatus == .completed || self.requestStatus == .expired {
            self.assignmentStatus = .cannotOffer
        }
        
        self.isOfferSubmitted = (self.assignmentStatus == .offered)
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
            self.requestStatus = entity.requestStatus
            self.assignmentStatus = entity.resolvedAssignmentStatus
            if self.assignmentStatus == .offered {
                self.isOfferSubmitted = true
            }
            self.state = .loaded
        } catch {
            let errMsg = (error as? NetworkError)?.errorDescription ?? error.localizedDescription
            self.state = .failed(errMsg)
        }
    }

    func loadPrescriptionImage() async {
        guard let urlString = requestModel?.prescriptionImageUrl else { return }
        let dataSource = prescriptionImageDataSource ?? PharmacyAppAssembler.shared.container.resolve(PrescriptionImageDataSource.self)
        do {
            let image = try await dataSource.fetchImage(urlString: urlString)
            self.prescriptionUIImage = image
        } catch {
            print("[ViewModel] Failed to load prescription image: \(error)")
        }
    }

    func updateSelectedProductId(for itemId: String, productId: Int) {
        guard var model = requestModel else { return }
        if let idx = model.items.firstIndex(where: { $0.id == itemId }) {
            model.items[idx].selectedOfferProductId = productId
            self.requestModel = model
        }
    }

    func replaceItem(_ item: PharmacyOrderItem, with product: PharmacyProductDTO) {
        guard var model = requestModel else { return }
        if let idx = model.items.firstIndex(where: { $0.id == item.id }) {
            let updatedItem = PharmacyOrderItem(
                id: item.id,
                requestItemId: item.requestItemId,
                productId: product.id,
                name: product.productName ?? product.name ?? item.name,
                spec: item.spec,
                quantity: item.quantity,
                price: product.price ?? item.price,
                imageName: item.imageName,
                imageUrl: product.imageUrl ?? item.imageUrl,
                isAvailable: true,
                selectedOfferProductId: product.id,
                alternativeMedicine: product.productName ?? product.name,
                form: product.form ?? item.form,
                strength: product.strength ?? item.strength,
                packSize: product.packSize ?? item.packSize
            )
            model.items[idx] = updatedItem
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
            self.alertMessage = "pharmacy.request.alert.select_item".localized
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
                self.assignmentStatus = .offered
                self.alertMessage = "pharmacy.request.alert.offer_sent_success".localized
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
