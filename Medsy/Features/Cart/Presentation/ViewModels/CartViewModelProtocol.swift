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
    case setPrescription(Data, CartPrescriptionSource)
    case replacePrescription(id: UUID, data: Data, source: CartPrescriptionSource)
    case removePrescriptionByID(UUID)
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

@MainActor
protocol CartViewModelProtocol: AnyObject {
    var state: CartViewState { get }
    var removedItem: CartDisplayItem? { get }
    var feedback: CartFeedback? { get }
    var feedbackSequence: Int { get }
    var syncState: CartSyncState { get }
    var prescriptions: [CartPrescriptionAttachment] { get }
    var itemCount: Int { get }
    var estimatedTotal: Double { get }
    var hasContent: Bool { get }

    @discardableResult
    func handle(_ event: CartEvent) -> CartEffect?
}
