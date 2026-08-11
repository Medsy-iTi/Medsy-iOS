//
//  CompleteRequestViewModel.swift
//  Medsy
//
//  Created by Ehab Salah on 24/07/2026.
//

import Foundation
import Observation

@MainActor
@Observable
final class CompleteRequestViewModel: CompleteRequestViewModelProtocol {
    let draft: CompleteRequestDraft
    var receiveMethod: CompleteRequestReceiveMethod = .delivery
    var paymentMethod: CompleteRequestPaymentMethod = .cash
    private(set) var savedAddress: String?
    private(set) var deliveryLocation: CompleteRequestLocation?
    var notes = ""
    var isSummaryExpanded = false
    private(set) var isLoadingAddress = false
    private(set) var isSubmitting = false
    private(set) var submissionErrorMessage: String?
    private(set) var validationErrors: [CompleteRequestValidationError] = []
    private(set) var submittedRequest: SubmittedMedicineRequest?

    private let getCustomerProfileUseCase: GetCustomerProfileUseCaseProtocol
    private let submitCompleteRequestUseCase: SubmitCompleteRequestUseCaseProtocol
    private let statusStore: UserDefaultsStatusStoreProtocol?
    private let onRequestCreated: (CompleteRequestSubmission) async -> Bool
    private var hasLoadedAddress = false

    init(
        draft: CompleteRequestDraft,
        getCustomerProfileUseCase: GetCustomerProfileUseCaseProtocol,
        submitCompleteRequestUseCase: SubmitCompleteRequestUseCaseProtocol,
        statusStore: UserDefaultsStatusStoreProtocol? = nil,
        onRequestCreated: @escaping (CompleteRequestSubmission) async -> Bool
    ) {
        self.draft = draft
        self.getCustomerProfileUseCase = getCustomerProfileUseCase
        self.submitCompleteRequestUseCase = submitCompleteRequestUseCase
        self.statusStore = statusStore
        self.onRequestCreated = onRequestCreated
    }

    var showsDeliveryDetails: Bool {
        receiveMethod == .delivery
    }

    var showsOnlinePaymentInfo: Bool {
        showsDeliveryDetails && paymentMethod == .online
    }

    var canSubmit: Bool {
        !isSubmitting && currentValidationErrors.isEmpty
    }

    func loadSavedAddress() async {
        guard !hasLoadedAddress else { return }
        hasLoadedAddress = true
        isLoadingAddress = true
        defer { isLoadingAddress = false }

        guard let profile = try? await getCustomerProfileUseCase.execute(),
              let address = profile.homeAddress?.trimmingCharacters(in: .whitespacesAndNewlines),
              !address.isEmpty else {
            return
        }

        savedAddress = address
        guard let latitude = profile.homeLatitude,
              let longitude = profile.homeLongitude else {
            return
        }

        let location = CompleteRequestLocation(
            address: address,
            latitude: latitude,
            longitude: longitude
        )
        if location.hasValidCoordinate, deliveryLocation == nil {
            deliveryLocation = location
        }
    }

    func selectReceiveMethod(_ method: CompleteRequestReceiveMethod) {
        receiveMethod = method
        clearValidationFeedback()
    }

    func selectPaymentMethod(_ method: CompleteRequestPaymentMethod) {
        paymentMethod = method
        clearValidationFeedback()
    }

    func confirmLocation(_ location: CompleteRequestLocation) {
        guard location.hasValidCoordinate,
              !location.address.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            return
        }
        deliveryLocation = location
        savedAddress = location.address
        clearValidationFeedback()
    }

    func dismissSubmissionError() {
        submissionErrorMessage = nil
    }

    func submit() async -> Bool {
        guard !isSubmitting else { return false }

        let errors = currentValidationErrors
        validationErrors = errors
        submissionErrorMessage = nil
        guard errors.isEmpty else {
            if errors.contains(.pickupUnsupported) {
                submissionErrorMessage = CompleteRequestValidationError
                    .pickupUnsupported
                    .localizedMessage
            }
            return false
        }

        isSubmitting = true
        defer { isSubmitting = false }

        guard let deliveryLocation else {
            validationErrors = [.locationRequired]
            return false
        }

        let submission = CompleteRequestSubmission(
            receiveMethod: receiveMethod,
            deliveryLocation: deliveryLocation,
            paymentMethod: paymentMethod,
            itemCount: draft.itemCount,
            prescriptionCount: draft.prescriptionCount,
            estimatedTotal: draft.estimatedTotal
        )

        if submittedRequest == nil {
            do {
                let result = try await submitCompleteRequestUseCase.execute(
                    input: SubmitCompleteRequestInput(
                        deliveryLatitude: deliveryLocation.latitude,
                                       deliveryLongitude: deliveryLocation.longitude,
                                       deliveryAddress: deliveryLocation.address,
                        notes: notes.trimmingCharacters(in: .whitespacesAndNewlines),
                        paymentMethod: paymentMethod.rawValue,
                        prescriptionData: draft.prescriptionData
                    )
                )
                submittedRequest = result
                statusStore?.savePendingRequestId(result.id)
            } catch {
                submissionErrorMessage = error.localizedDescription
                return false
            }
        }

        guard await onRequestCreated(submission) else {
            submissionErrorMessage = "complete_request.submit_error".localized
            return false
        }
        return true
    }

    private var currentValidationErrors: [CompleteRequestValidationError] {
        guard receiveMethod == .delivery else { return [.pickupUnsupported] }

        var errors: [CompleteRequestValidationError] = []
        if deliveryLocation == nil {
            errors.append(.locationRequired)
        }

        return errors
    }

    private func clearValidationFeedback() {
        validationErrors = []
        submissionErrorMessage = nil
    }
}
