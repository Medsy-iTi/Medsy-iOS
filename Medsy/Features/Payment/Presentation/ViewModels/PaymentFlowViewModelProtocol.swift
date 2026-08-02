//
//  PaymentFlowViewModelProtocol.swift
//  Medsy
//
//  Created by Ahmed Elkady on 02/08/2026.
//

import Foundation

struct PaymentSheetPresentationRequest: Equatable, Sendable {
    let orderId: Int
    let opaqueReference: String
}

enum PaymentPreparationResult: Equatable, Sendable {
    case cash
    case online(PaymentSheetPresentationRequest)
}

enum PaymentSheetPresentationOutcome: Equatable, Sendable {
    case completed
    case cancelled
    case failed(message: String?)
}

enum PaymentConfirmationPresentationStatus: Equatable, Sendable {
    case pending
    case paid
    case failed(message: String?)
}

protocol PaymentPreparingProtocol {
    func prepare(orderId: Int) async throws -> PaymentPreparationResult
}

protocol PaymentSheetPresentingProtocol {
    func present(_ request: PaymentSheetPresentationRequest) async -> PaymentSheetPresentationOutcome
}

protocol PaymentConfirmationRefreshingProtocol {
    func refresh(orderId: Int) async throws -> PaymentConfirmationPresentationStatus
}

enum PaymentFlowViewState: Equatable {
    case idle
    case loading
    case presenting
    case processing
    case success
    case failure(message: String?)
    case cancelled
    case unsupportedCombinedOrder

    var statusPresentation: PaymentStatusPresentation {
        switch self {
        case .idle, .loading, .presenting, .processing:
            .processing
        case .success:
            .success
        case .failure(let message):
            .failure(message: message)
        case .cancelled:
            .cancelled
        case .unsupportedCombinedOrder:
            .unsupportedCombinedOrder
        }
    }

    var isBusy: Bool {
        switch self {
        case .loading, .presenting:
            true
        case .idle, .processing, .success, .failure, .cancelled, .unsupportedCombinedOrder:
            false
        }
    }
}

enum PaymentFlowEvent {
    case start
    case retry
    case refreshStatus
}

@MainActor
protocol PaymentFlowViewModelProtocol: AnyObject {
    var state: PaymentFlowViewState { get }
    var orderId: Int? { get }

    func handle(_ event: PaymentFlowEvent) async
}
