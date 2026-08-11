//
//  PaymentFlowViewModelProtocol.swift
//  Medsy
//
//  Created by Ahmed Elkady on 02/08/2026.
//

import Foundation

struct PaymentSheetPresentationRequest: Equatable, Sendable {
    let masterOrderId: Int
    let opaqueReference: String
}

enum PaymentOrderPresentationStatus: Equatable, Sendable {
    case cash
    case cardPending(expiresAt: Date?)
    case paid
    case expired
    case cancelled
    case failed(message: String?)
}

enum PaymentSheetPresentationOutcome: Equatable, Sendable {
    case completed
    case cancelled
    case failed(message: String?)
}

protocol PaymentPreparingProtocol {
    func prepare(masterOrderId: Int) async throws -> PaymentSheetPresentationRequest
}

protocol PaymentSheetPresentingProtocol {
    func present(_ request: PaymentSheetPresentationRequest) async -> PaymentSheetPresentationOutcome
}

protocol PaymentOrderRefreshingProtocol {
    func refresh(masterOrderId: Int) async throws -> PaymentOrderPresentationStatus
}

enum PaymentFlowViewState: Equatable {
    case idle
    case loading
    case presenting
    case processing
    case success
    case failure(message: String?)
    case cancelled
    case expired

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
        case .expired:
            .expired
        }
    }

    var isBusy: Bool {
        switch self {
        case .loading, .presenting:
            true
        case .idle, .processing, .success, .failure, .cancelled, .expired:
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
    var masterOrderId: Int { get }

    func handle(_ event: PaymentFlowEvent) async
}
