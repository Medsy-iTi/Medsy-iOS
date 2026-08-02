//
//  CompleteRequestViewModelProtocol.swift
//  Medsy
//
//  Created by Ehab Salah on 24/07/2026.
//

import Foundation

@MainActor
protocol CompleteRequestViewModelProtocol: AnyObject {
    var draft: CompleteRequestDraft { get }
    var receiveMethod: CompleteRequestReceiveMethod { get set }
    var paymentMethod: CompleteRequestPaymentMethod { get set }
    var savedAddress: String? { get }
    var deliveryLocation: CompleteRequestLocation? { get }
    var notes: String { get set }
    var isSummaryExpanded: Bool { get set }
    var isLoadingAddress: Bool { get }
    var isSubmitting: Bool { get }
    var submissionErrorMessage: String? { get }
    var validationErrors: [CompleteRequestValidationError] { get }
    var submittedRequest: SubmittedMedicineRequest? { get }
    var showsDeliveryDetails: Bool { get }
    var showsOnlinePaymentInfo: Bool { get }
    var canSubmit: Bool { get }

    func loadSavedAddress() async
    func selectReceiveMethod(_ method: CompleteRequestReceiveMethod)
    func selectPaymentMethod(_ method: CompleteRequestPaymentMethod)
    func confirmLocation(_ location: CompleteRequestLocation)
    func dismissSubmissionError()
    func submit() async -> Bool
}
