//
//  CartViewModelProtocol.swift
//  Medsy
//
//  Created by Ahmed Elkady on 19/07/2026.
//

import Foundation

enum CartEvent: Equatable {
    case load
    case addItem(CartDisplayItem)
    case increaseQuantity(itemID: String)
    case decreaseQuantity(itemID: String)
    case removeItem(itemID: String)
    case undoRemoval
    case dismissRemoval
    case setPrescription(Data, CartPrescriptionSource)
    case replacePrescription(id: UUID, data: Data, source: CartPrescriptionSource)
    case removePrescriptionByID(UUID)
    case updatePharmacistNote(String)
    case clear
    case retry
    case dismissFeedback
    case syncStarted
    case syncSucceeded([CartDisplayItem])
    case syncFailed(String)
    case continueRequest
}

enum CartEffect: Equatable {
    case load
    case sync
    case persistPrescription
    case continueRequest(CartRequestDraft)
}

enum CartFeedback: Equatable {
    case itemAdded(String)
    case maximumItemCountReached(Int)
    case operationFailed(String)
}

enum CartSyncState: Equatable {
    case idle
    case syncing
    case synced
    case failed(String)
}

enum CartInteractionsState: Equatable {
    case idle
    case loading
    case loaded
    case failed(String)
}

@MainActor
protocol CartViewModelProtocol: AnyObject {
    var state: CartViewState { get }
    var removedItem: CartDisplayItem? { get }
    var feedback: CartFeedback? { get }
    var feedbackSequence: Int { get }
    var syncState: CartSyncState { get }
    var interactionWarnings: [CartInteractionWarning] { get }
    var interactionsState: CartInteractionsState { get }
    var prescriptions: [CartPrescriptionAttachment] { get }
    var pharmacistNote: String { get }
    var itemCount: Int { get }
    var estimatedTotal: Double { get }
    var hasContent: Bool { get }

    @discardableResult
    func handle(_ event: CartEvent) -> CartEffect?
    func attachPrescription(data: Data, source: CartPrescriptionSource) async throws
    func refreshInteractions(language: String) async
    func clearAfterCompletedRequest() async -> Bool
}
