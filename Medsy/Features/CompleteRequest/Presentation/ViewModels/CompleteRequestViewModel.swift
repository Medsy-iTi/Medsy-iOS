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
    var cardholderName = ""
    var cardNumber = ""
    var expiry = ""
    var cvv = ""
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
    private let now: () -> Date
    private var hasLoadedAddress = false

    init(
        draft: CompleteRequestDraft,
        getCustomerProfileUseCase: GetCustomerProfileUseCaseProtocol,
        submitCompleteRequestUseCase: SubmitCompleteRequestUseCaseProtocol,
        statusStore: UserDefaultsStatusStoreProtocol? = nil,
        now: @escaping () -> Date = Date.init,
        onRequestCreated: @escaping (CompleteRequestSubmission) async -> Bool
    ) {
        self.draft = draft
        self.getCustomerProfileUseCase = getCustomerProfileUseCase
        self.submitCompleteRequestUseCase = submitCompleteRequestUseCase
        self.statusStore = statusStore
        self.now = now
        self.onRequestCreated = onRequestCreated
    }

    var showsDeliveryDetails: Bool {
        receiveMethod == .delivery
    }

    var showsVisaForm: Bool {
        showsDeliveryDetails && paymentMethod == .visa
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

    func formatCardNumber() {
        let digits = cardNumber.filter(\.isNumber).prefix(16)
        cardNumber = stride(from: 0, to: digits.count, by: 4)
            .map { start in
                let startIndex = digits.index(digits.startIndex, offsetBy: start)
                let endIndex = digits.index(
                    startIndex,
                    offsetBy: min(4, digits.distance(from: startIndex, to: digits.endIndex))
                )
                return String(digits[startIndex..<endIndex])
            }
            .joined(separator: " ")
    }

    func formatExpiry() {
        let digits = String(expiry.filter(\.isNumber).prefix(4))
        if digits.count > 2 {
            expiry = "\(digits.prefix(2))/\(digits.dropFirst(2))"
        } else {
            expiry = digits
        }
    }

    func formatCVV() {
        cvv = String(cvv.filter(\.isNumber).prefix(3))
    }

    func validationMessage(for field: CompleteRequestCardField) -> String? {
        let error: CompleteRequestValidationError
        switch field {
        case .cardholderName:
            error = .cardholderNameRequired
        case .cardNumber:
            error = .invalidCardNumber
        case .expiry:
            error = .invalidExpiry
        case .cvv:
            error = .invalidCVV
        }
        return validationErrors.contains(error) ? error.localizedMessage : nil
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

        guard paymentMethod == .visa else { return errors }
        if cardholderName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            errors.append(.cardholderNameRequired)
        }
        if !isValidVisaNumber {
            errors.append(.invalidCardNumber)
        }
        if !isValidExpiry {
            errors.append(.invalidExpiry)
        }
        if cvv.count != 3 || !cvv.allSatisfy(\.isNumber) {
            errors.append(.invalidCVV)
        }
        return errors
    }

    private var isValidVisaNumber: Bool {
        let digits = cardNumber.filter(\.isNumber)
        guard digits.count == 16, digits.first == "4" else { return false }

        let values = digits.compactMap(\.wholeNumberValue)
        guard values.count == 16 else { return false }
        let checksum = values.reversed().enumerated().reduce(0) { result, entry in
            let (index, value) = entry
            guard index.isMultiple(of: 2) == false else {
                return result + value
            }
            let doubled = value * 2
            return result + (doubled > 9 ? doubled - 9 : doubled)
        }
        return checksum.isMultiple(of: 10)
    }

    private var isValidExpiry: Bool {
        let parts = expiry.split(separator: "/")
        guard parts.count == 2,
              let month = Int(parts[0]),
              let year = Int(parts[1]),
              (1...12).contains(month) else {
            return false
        }

        let calendar = Calendar(identifier: .gregorian)
        let currentYear = calendar.component(.year, from: now()) % 100
        let currentMonth = calendar.component(.month, from: now())
        return year > currentYear || (year == currentYear && month >= currentMonth)
    }

    private func clearValidationFeedback() {
        validationErrors = []
        submissionErrorMessage = nil
    }
}
