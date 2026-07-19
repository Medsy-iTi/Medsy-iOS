//
//  CartViewModel.swift
//  Medsy
//
//  Created by Ahmed Elkady on 19/07/2026.
//

import Foundation
import Observation

@MainActor
@Observable
final class CartViewModel: CartViewModelProtocol {
    private(set) var state: CartViewState
    private(set) var removedItem: CartDisplayItem?
    private(set) var feedback: CartFeedback?
    private(set) var syncState: CartSyncState = .idle
    private(set) var prescription: CartPrescriptionAttachment?

    private let maximumItemCount: Int
    private var removedItemIndex: Int?

    init(
        items: [CartDisplayItem] = [],
        prescription: CartPrescriptionAttachment? = nil,
        maximumItemCount: Int = 20
    ) {
        state = items.isEmpty ? .empty : .loaded(items)
        self.prescription = prescription
        self.maximumItemCount = maximumItemCount
    }

    init(
        state: CartViewState,
        prescription: CartPrescriptionAttachment? = nil,
        maximumItemCount: Int = 20
    ) {
        self.state = state
        self.prescription = prescription
        self.maximumItemCount = maximumItemCount
    }

    var itemCount: Int {
        items.reduce(0) { $0 + $1.quantity }
    }

    var estimatedTotal: Double {
        items.reduce(0) { $0 + $1.lineTotal }
    }

    var hasContent: Bool {
        !items.isEmpty || prescription != nil
    }

    func quantity(forProductID productID: Int64?) -> Int {
        guard let productID else { return 0 }
        return items.first(where: { $0.productID == productID })?.quantity ?? 0
    }

    @discardableResult
    func handle(_ event: CartEvent) -> CartEffect? {
        switch event {
        case .load, .retry:
            if items.isEmpty {
                state = .loading
            }
            return .load
        case let .addItem(item):
            return add(item) ? .sync : nil
        case let .increaseQuantity(itemID):
            return increaseQuantity(itemID: itemID) ? .sync : nil
        case let .decreaseQuantity(itemID):
            return decreaseQuantity(itemID: itemID) ? .sync : nil
        case let .removeItem(itemID):
            return removeItem(itemID: itemID) ? .sync : nil
        case .undoRemoval:
            return undoRemoval() ? .sync : nil
        case let .setPrescription(data, source):
            guard !data.isEmpty else { return nil }
            prescription = CartPrescriptionAttachment(imageData: data, source: source)
            feedback = nil
            return .persistPrescription
        case .removePrescription:
            guard prescription != nil else { return nil }
            prescription = nil
            return .persistPrescription
        case .clear:
            replaceItems([])
            prescription = nil
            clearRemoval()
            return .sync
        case .dismissFeedback:
            feedback = nil
        case .syncStarted:
            syncState = .syncing
        case let .syncSucceeded(items):
            replaceItems(items)
            syncState = .synced
            feedback = nil
        case let .syncFailed(message):
            syncState = .failed(message)
            feedback = .operationFailed(message)
        case .continueRequest:
            guard hasContent else { return nil }
            return .continueRequest(
                CartRequestDraft(
                    items: items,
                    prescription: prescription
                )
            )
        }

        return nil
    }

    private var items: [CartDisplayItem] {
        guard case let .loaded(items) = state else { return [] }
        return items
    }

    private func add(_ item: CartDisplayItem) -> Bool {
        guard item.quantity > 0 else { return false }
        guard itemCount + item.quantity <= maximumItemCount else {
            feedback = .maximumItemCountReached(maximumItemCount)
            return false
        }

        var updatedItems = items
        if let index = updatedItems.firstIndex(where: { $0.duplicateIdentity == item.duplicateIdentity }) {
            let existingItem = updatedItems[index]
            updatedItems[index] = existingItem.updating(quantity: existingItem.quantity + item.quantity)
        } else {
            updatedItems.append(item)
        }

        feedback = nil
        replaceItems(updatedItems)
        return true
    }

    private func increaseQuantity(itemID: String) -> Bool {
        guard itemCount < maximumItemCount else {
            feedback = .maximumItemCountReached(maximumItemCount)
            return false
        }

        var updatedItems = items
        guard let index = updatedItems.firstIndex(where: { $0.id == itemID }) else { return false }
        updatedItems[index] = updatedItems[index].updating(quantity: updatedItems[index].quantity + 1)
        feedback = nil
        replaceItems(updatedItems)
        return true
    }

    private func decreaseQuantity(itemID: String) -> Bool {
        guard let item = items.first(where: { $0.id == itemID }) else { return false }
        if item.quantity <= 1 {
            return removeItem(itemID: itemID)
        }

        var updatedItems = items
        guard let index = updatedItems.firstIndex(where: { $0.id == itemID }) else { return false }
        updatedItems[index] = item.updating(quantity: item.quantity - 1)
        feedback = nil
        replaceItems(updatedItems)
        return true
    }

    private func removeItem(itemID: String) -> Bool {
        var updatedItems = items
        guard let index = updatedItems.firstIndex(where: { $0.id == itemID }) else { return false }
        removedItem = updatedItems.remove(at: index)
        removedItemIndex = index
        feedback = nil
        replaceItems(updatedItems)
        return true
    }

    private func undoRemoval() -> Bool {
        guard let removedItem else { return false }
        var updatedItems = items
        let index = min(removedItemIndex ?? updatedItems.endIndex, updatedItems.endIndex)
        updatedItems.insert(removedItem, at: index)
        replaceItems(updatedItems)
        clearRemoval()
        feedback = nil
        return true
    }

    private func replaceItems(_ items: [CartDisplayItem]) {
        state = items.isEmpty ? .empty : .loaded(items)
    }

    private func clearRemoval() {
        removedItem = nil
        removedItemIndex = nil
    }
}
