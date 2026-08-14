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
    private(set) var feedbackSequence = 0
    private(set) var syncState: CartSyncState = .idle
    private(set) var prescriptions: [CartPrescriptionAttachment]
    private(set) var pharmacistNote = ""
    private(set) var interactionWarnings: [CartInteractionWarning]
    private(set) var interactionsState: CartInteractionsState = .idle

    private let loadCartUseCase: LoadCartUseCaseProtocol?
    private let addCartItemUseCase: AddCartItemUseCaseProtocol?
    private let updateCartItemQuantityUseCase: UpdateCartItemQuantityUseCaseProtocol?
    private let removeCartItemUseCase: RemoveCartItemUseCaseProtocol?
    private let clearCartUseCase: ClearCartUseCaseProtocol?
    private let manageCartPrescriptionsUseCase: ManageCartPrescriptionsUseCaseProtocol?
    private let getCartInteractionsUseCase: GetCartInteractionsUseCaseProtocol?
    private let maximumItemCount: Int
    private var removedItemIndex: Int?
    private var loadTask: Task<Void, Never>?
    private var operationTask: Task<Void, Never>?
    private var interactionLanguage: String
    private var interactionRequestSequence = 0

    init(
        loadCartUseCase: LoadCartUseCaseProtocol,
        addCartItemUseCase: AddCartItemUseCaseProtocol,
        updateCartItemQuantityUseCase: UpdateCartItemQuantityUseCaseProtocol,
        removeCartItemUseCase: RemoveCartItemUseCaseProtocol,
        clearCartUseCase: ClearCartUseCaseProtocol,
        manageCartPrescriptionsUseCase: ManageCartPrescriptionsUseCaseProtocol,
        getCartInteractionsUseCase: GetCartInteractionsUseCaseProtocol,
        interactionLanguage: String,
        maximumItemCount: Int = 20
    ) {
        state = .loading
        prescriptions = []
        interactionWarnings = []
        self.loadCartUseCase = loadCartUseCase
        self.addCartItemUseCase = addCartItemUseCase
        self.updateCartItemQuantityUseCase = updateCartItemQuantityUseCase
        self.removeCartItemUseCase = removeCartItemUseCase
        self.clearCartUseCase = clearCartUseCase
        self.manageCartPrescriptionsUseCase = manageCartPrescriptionsUseCase
        self.getCartInteractionsUseCase = getCartInteractionsUseCase
        self.interactionLanguage = Self.normalizedLanguage(interactionLanguage)
        self.maximumItemCount = maximumItemCount
    }

    init(
        items: [CartDisplayItem] = [],
        prescriptions: [CartPrescriptionAttachment] = [],
        interactionWarnings: [CartInteractionWarning] = [],
        getCartInteractionsUseCase: GetCartInteractionsUseCaseProtocol? = nil,
        interactionLanguage: String = "en",
        maximumItemCount: Int = 20
    ) {
        state = items.isEmpty ? .empty : .loaded(items)
        self.prescriptions = prescriptions.suffix(1).map { $0 }
        self.interactionWarnings = interactionWarnings
        loadCartUseCase = nil
        addCartItemUseCase = nil
        updateCartItemQuantityUseCase = nil
        removeCartItemUseCase = nil
        clearCartUseCase = nil
        manageCartPrescriptionsUseCase = nil
        self.getCartInteractionsUseCase = getCartInteractionsUseCase
        self.interactionLanguage = Self.normalizedLanguage(interactionLanguage)
        interactionsState = .loaded
        self.maximumItemCount = maximumItemCount
    }

    init(
        state: CartViewState,
        prescriptions: [CartPrescriptionAttachment] = [],
        interactionWarnings: [CartInteractionWarning] = [],
        maximumItemCount: Int = 20
    ) {
        self.state = state
        self.prescriptions = prescriptions.suffix(1).map { $0 }
        self.interactionWarnings = interactionWarnings
        loadCartUseCase = nil
        addCartItemUseCase = nil
        updateCartItemQuantityUseCase = nil
        removeCartItemUseCase = nil
        clearCartUseCase = nil
        manageCartPrescriptionsUseCase = nil
        getCartInteractionsUseCase = nil
        interactionLanguage = "en"
        interactionsState = .loaded
        self.maximumItemCount = maximumItemCount
    }

    var itemCount: Int {
        items.reduce(0) { $0 + $1.quantity }
    }

    var distinctProductCount: Int {
        Set(items.map(\.duplicateIdentity)).count
    }

    var estimatedTotal: Double {
        items.reduce(0) { $0 + $1.lineTotal }
    }

    var hasContent: Bool {
        !items.isEmpty || !prescriptions.isEmpty
    }

    func attachPrescription(
        data: Data,
        source: CartPrescriptionSource
    ) async throws {
        guard canMutate else { throw CartPrescriptionReviewError.cartIsBusy }
        guard !data.isEmpty else { return }

        let previousPrescriptions = prescriptions
        let existingPrescription = prescriptions.first
        let attachment = CartPrescriptionAttachment(
            id: existingPrescription?.id ?? UUID(),
            imageData: data,
            source: source,
            createdAt: existingPrescription?.createdAt ?? Date()
        )

        prescriptions = [attachment]
        feedback = nil

        guard let manageCartPrescriptionsUseCase else {
            syncState = .synced
            return
        }

        syncState = .syncing
        do {
            let prescription = CartPrescriptionPresentationMapper.map(attachment)
            let updatedPrescriptions: [CartPrescription]
            if let existingPrescription {
                updatedPrescriptions = try await manageCartPrescriptionsUseCase.replace(
                    id: existingPrescription.id,
                    with: prescription
                )
            } else {
                updatedPrescriptions = try await manageCartPrescriptionsUseCase.add(prescription)
            }

            prescriptions = updatedPrescriptions.map(CartPrescriptionPresentationMapper.map)
            syncState = .synced
        } catch {
            prescriptions = previousPrescriptions
            let message = error.localizedDescription
            syncState = .failed(message)
            feedback = .operationFailed(message)
            throw error
        }
    }

    func addPrescriptionReview(
        items reviewItems: [CartDisplayItem],
        prescriptionData: Data?,
        source: CartPrescriptionSource?
    ) async throws {
        guard canMutate else { throw CartPrescriptionReviewError.cartIsBusy }
        guard !reviewItems.isEmpty,
              reviewItems.allSatisfy({ $0.productID != nil && $0.quantity > 0 }) else {
            throw CartPrescriptionReviewError.invalidMedicine
        }

        let requestedQuantity = reviewItems.reduce(0) { $0 + $1.quantity }
        guard itemCount + requestedQuantity <= maximumItemCount else {
            throw CartPrescriptionReviewError.maximumItemCountReached(maximumItemCount)
        }

        let previousItems = items
        let previousPrescriptions = prescriptions
        for item in reviewItems {
            guard add(item) else {
                replaceItems(previousItems)
                throw CartPrescriptionReviewError.invalidMedicine
            }
        }

        let attachment: CartPrescriptionAttachment?
        let replacedPrescriptionID = previousPrescriptions.first?.id
        if let prescriptionData, !prescriptionData.isEmpty, let source {
            let newAttachment = CartPrescriptionAttachment(
                id: replacedPrescriptionID ?? UUID(),
                imageData: prescriptionData,
                source: source,
                createdAt: previousPrescriptions.first?.createdAt ?? Date()
            )
            attachment = newAttachment
            prescriptions = [newAttachment]
        } else {
            attachment = nil
        }

        guard let addCartItemUseCase else {
            syncState = .synced
            return
        }

        syncState = .syncing
        do {
            var updatedCart: Cart?
            for item in reviewItems {
                guard let productID = item.productID else {
                    throw CartPrescriptionReviewError.invalidMedicine
                }
                updatedCart = try await addCartItemUseCase.execute(
                    input: AddCartItemInput(
                        productID: productID,
                        quantity: item.quantity,
                        dosageInfo: item.dosageInfo
                    )
                )
            }

            guard let updatedCart else {
                throw CartPrescriptionReviewError.invalidMedicine
            }

            var updatedPrescriptions = updatedCart.prescriptions
            if let attachment, let manageCartPrescriptionsUseCase {
                let prescription = CartPrescriptionPresentationMapper.map(attachment)
                if let replacedPrescriptionID {
                    updatedPrescriptions = try await manageCartPrescriptionsUseCase.replace(
                        id: replacedPrescriptionID,
                        with: prescription
                    )
                } else {
                    updatedPrescriptions = try await manageCartPrescriptionsUseCase.add(prescription)
                }
            }

            apply(updatedCart.withPrescriptions(updatedPrescriptions))
            syncState = .synced
            feedback = nil
            await refreshInteractions(language: interactionLanguage)
        } catch {
            if let loadCartUseCase, let refreshedCart = try? await loadCartUseCase.refresh() {
                apply(refreshedCart)
            } else {
                replaceItems(previousItems)
                prescriptions = previousPrescriptions
            }
            let message = error.localizedDescription
            syncState = .failed(message)
            feedback = .operationFailed(message)
            throw error
        }
    }

    func quantity(forProductID productID: Int64?) -> Int {
        guard let productID else { return 0 }
        return items.first(where: { $0.productID == productID })?.quantity ?? 0
    }

    func itemID(forProductID productID: Int64?) -> String? {
        guard let productID else { return nil }
        return items.first(where: { $0.productID == productID })?.id
    }

    @discardableResult
    func handle(_ event: CartEvent) -> CartEffect? {
        switch event {
        case .load, .retry:
            load()
            return .load
        case let .addItem(item):
            return handleAdd(item)
        case let .increaseQuantity(itemID):
            return handleIncrease(itemID: itemID)
        case let .decreaseQuantity(itemID):
            return handleDecrease(itemID: itemID)
        case let .removeItem(itemID):
            return handleRemove(itemID: itemID)
        case .undoRemoval:
            return handleUndoRemoval()
        case .dismissRemoval:
            clearRemoval()
        case let .setPrescription(data, source):
            return handleAddPrescription(data: data, source: source)
        case let .replacePrescription(id, data, source):
            return handleReplacePrescription(id: id, data: data, source: source)
        case let .removePrescriptionByID(id):
            return handleRemovePrescription(id: id)
        case let .updatePharmacistNote(note):
            pharmacistNote = String(note.prefix(500))
        case .clear:
            return handleClear()
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
                    prescriptions: prescriptions,
                    pharmacistNote: pharmacistNote
                )
            )
        }

        return nil
    }

    func clearAfterCompletedRequest() async -> Bool {
        guard canMutate else { return !hasContent }

        if let clearCartUseCase {
            do {
                try await clearCartUseCase.clearAfterCompletedRequest()
            } catch {
                // The backend has already created the request and cleared its cart.
                // Keep completion navigation independent from a local cache cleanup failure.
            }
        }

        replaceItems([])
        prescriptions = []
        pharmacistNote = ""
        clearRemoval()
        clearInteractions()
        syncState = .synced
        feedback = nil
        return true
    }

    func refreshInteractions(language: String) async {
        interactionLanguage = Self.normalizedLanguage(language)
        interactionRequestSequence += 1
        let requestSequence = interactionRequestSequence

        guard !items.isEmpty, let getCartInteractionsUseCase else {
            interactionWarnings = []
            interactionsState = .loaded
            return
        }

        interactionWarnings = []
        interactionsState = .loading
        do {
            let warnings = try await getCartInteractionsUseCase.execute(language: interactionLanguage)
            guard requestSequence == interactionRequestSequence else { return }
            interactionWarnings = warnings
            interactionsState = .loaded
        } catch is CancellationError {
            return
        } catch {
            guard requestSequence == interactionRequestSequence else { return }
            interactionWarnings = []
            interactionsState = .failed(error.localizedDescription)
        }
    }

    private var items: [CartDisplayItem] {
        guard case let .loaded(items) = state else { return [] }
        return items
    }

    private var canMutate: Bool {
        syncState != .syncing
    }

    private func load() {
        guard let loadCartUseCase else {
            if items.isEmpty {
                state = .loading
            }
            return
        }

        loadTask?.cancel()
        if items.isEmpty && prescriptions.isEmpty {
            state = .loading
        }
        loadTask = Task {
            var hasCachedCart = false
            do {
                let cachedCart = try await loadCartUseCase.cached()
                guard !Task.isCancelled else { return }
                hasCachedCart = cachedCart.id != nil || cachedCart.hasContent
                apply(cachedCart)
            } catch is CancellationError {
                return
            } catch {
                hasCachedCart = false
            }

            syncState = .syncing
            do {
                let cart = try await loadCartUseCase.refresh()
                guard !Task.isCancelled else { return }
                apply(cart)
                syncState = .synced
                feedback = nil
                await refreshInteractions(language: interactionLanguage)
            } catch is CancellationError {
                return
            } catch {
                let message = error.localizedDescription
                syncState = .failed(message)
                if !hasCachedCart {
                    state = .error(message)
                } else {
                    feedback = .operationFailed(message)
                }
            }
        }
    }

    private func handleAdd(_ item: CartDisplayItem) -> CartEffect? {
        guard canMutate else { return nil }
        guard addCartItemUseCase == nil || item.productID != nil else {
            feedback = .operationFailed("Unable to add this medicine to the cart.")
            return nil
        }

        let previousItems = items
        guard add(item) else { return nil }
        guard let addCartItemUseCase, let productID = item.productID else { return .sync }

        startCartMutation(previousItems: previousItems) {
            try await addCartItemUseCase.execute(
                input: AddCartItemInput(
                    productID: productID,
                    quantity: item.quantity,
                    dosageInfo: item.dosageInfo
                )
            )
        }
        return .sync
    }

    private func handleIncrease(itemID: String) -> CartEffect? {
        guard canMutate else { return nil }
        let previousItems = items
        guard let item = items.first(where: { $0.id == itemID }),
              increaseQuantity(itemID: itemID) else {
            return nil
        }
        guard let useCase = updateCartItemQuantityUseCase,
              let cartItemID = item.cartItemID else {
            return .sync
        }

        startCartMutation(previousItems: previousItems, refreshInteractionsAfterSync: false) {
            try await useCase.execute(itemID: cartItemID, quantity: item.quantity + 1)
        }
        return .sync
    }

    private func handleDecrease(itemID: String) -> CartEffect? {
        guard canMutate else { return nil }
        guard let item = items.first(where: { $0.id == itemID }) else { return nil }
        if item.quantity <= 1 {
            return handleRemove(itemID: itemID)
        }

        let previousItems = items
        guard decreaseQuantity(itemID: itemID) else { return nil }
        guard let useCase = updateCartItemQuantityUseCase,
              let cartItemID = item.cartItemID else {
            return .sync
        }

        startCartMutation(previousItems: previousItems, refreshInteractionsAfterSync: false) {
            try await useCase.execute(itemID: cartItemID, quantity: item.quantity - 1)
        }
        return .sync
    }

    private func handleRemove(itemID: String) -> CartEffect? {
        guard canMutate else { return nil }
        let previousItems = items
        guard let item = items.first(where: { $0.id == itemID }),
              removeItem(itemID: itemID) else {
            return nil
        }
        guard let useCase = removeCartItemUseCase,
              let cartItemID = item.cartItemID else {
            return .sync
        }

        startCartMutation(previousItems: previousItems) {
            try await useCase.execute(itemID: cartItemID)
        }
        return .sync
    }

    private func handleUndoRemoval() -> CartEffect? {
        guard canMutate, let item = removedItem else { return nil }
        let previousItems = items
        guard undoRemoval() else { return nil }
        guard let useCase = addCartItemUseCase,
              let productID = item.productID else {
            return .sync
        }

        startCartMutation(previousItems: previousItems) {
            try await useCase.execute(
                input: AddCartItemInput(
                    productID: productID,
                    quantity: item.quantity,
                    dosageInfo: item.dosageInfo
                )
            )
        }
        return .sync
    }

    private func handleAddPrescription(
        data: Data,
        source: CartPrescriptionSource
    ) -> CartEffect? {
        guard canMutate, !data.isEmpty else { return nil }
        let previousPrescriptions = prescriptions
        let existingPrescription = prescriptions.first
        let attachment = CartPrescriptionAttachment(
            id: existingPrescription?.id ?? UUID(),
            imageData: data,
            source: source,
            createdAt: existingPrescription?.createdAt ?? Date()
        )
        prescriptions = [attachment]
        feedback = nil
        guard let useCase = manageCartPrescriptionsUseCase else { return .persistPrescription }

        startPrescriptionMutation(previousPrescriptions: previousPrescriptions) {
            let prescription = CartPrescriptionPresentationMapper.map(attachment)
            if let existingPrescription {
                return try await useCase.replace(id: existingPrescription.id, with: prescription)
            }
            return try await useCase.add(prescription)
        }
        return .persistPrescription
    }

    private func handleReplacePrescription(
        id: UUID,
        data: Data,
        source: CartPrescriptionSource
    ) -> CartEffect? {
        guard canMutate, !data.isEmpty,
              let index = prescriptions.firstIndex(where: { $0.id == id }) else {
            return nil
        }

        let previousPrescriptions = prescriptions
        let attachment = CartPrescriptionAttachment(
            id: id,
            imageData: data,
            source: source,
            createdAt: prescriptions[index].createdAt
        )
        prescriptions[index] = attachment
        guard let useCase = manageCartPrescriptionsUseCase else { return .persistPrescription }

        startPrescriptionMutation(previousPrescriptions: previousPrescriptions) {
            try await useCase.replace(
                id: id,
                with: CartPrescriptionPresentationMapper.map(attachment)
            )
        }
        return .persistPrescription
    }

    private func handleRemovePrescription(id: UUID) -> CartEffect? {
        guard canMutate,
              prescriptions.contains(where: { $0.id == id }) else {
            return nil
        }

        let previousPrescriptions = prescriptions
        prescriptions.removeAll { $0.id == id }
        guard let useCase = manageCartPrescriptionsUseCase else { return .persistPrescription }

        startPrescriptionMutation(previousPrescriptions: previousPrescriptions) {
            try await useCase.remove(id: id)
        }
        return .persistPrescription
    }

    private func handleClear() -> CartEffect? {
        guard canMutate, hasContent else { return nil }
        guard let clearCartUseCase else {
            replaceItems([])
            prescriptions = []
            pharmacistNote = ""
            clearRemoval()
            clearInteractions()
            return .sync
        }

        syncState = .syncing
        operationTask = Task {
            do {
                try await clearCartUseCase.execute()
                replaceItems([])
                prescriptions = []
                pharmacistNote = ""
                clearRemoval()
                clearInteractions()
                syncState = .synced
                feedback = nil
            } catch {
                let message = error.localizedDescription
                syncState = .failed(message)
                feedback = .operationFailed(message)
            }
        }
        return .sync
    }

    private func startCartMutation(
        previousItems: [CartDisplayItem],
        refreshInteractionsAfterSync: Bool = true,
        operation: @escaping () async throws -> Cart
    ) {
        let previousPrescriptions = prescriptions
        syncState = .syncing
        operationTask = Task {
            do {
                let cart = try await operation()
                apply(cart)
                syncState = .synced
                if refreshInteractionsAfterSync {
                    await refreshInteractions(language: interactionLanguage)
                }
            } catch {
                replaceItems(previousItems)
                prescriptions = previousPrescriptions
                let message = error.localizedDescription
                syncState = .failed(message)
                feedback = .operationFailed(message)
            }
        }
    }

    private func startPrescriptionMutation(
        previousPrescriptions: [CartPrescriptionAttachment],
        operation: @escaping () async throws -> [CartPrescription]
    ) {
        syncState = .syncing
        operationTask = Task {
            do {
                prescriptions = try await operation().map(CartPrescriptionPresentationMapper.map)
                syncState = .synced
            } catch {
                prescriptions = previousPrescriptions
                let message = error.localizedDescription
                syncState = .failed(message)
                feedback = .operationFailed(message)
            }
        }
    }

    private func apply(_ cart: Cart) {
        replaceItems(cart.items.map(CartItemPresentationMapper.map))
        prescriptions = cart.prescriptions.suffix(1).map(CartPrescriptionPresentationMapper.map)
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

        feedback = .itemAdded(item.name)
        feedbackSequence += 1
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
        var updatedItems = items
        guard let index = updatedItems.firstIndex(where: { $0.id == itemID }) else { return false }
        let item = updatedItems[index]
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

    private func clearInteractions() {
        interactionRequestSequence += 1
        interactionWarnings = []
        interactionsState = .loaded
    }

    private static func normalizedLanguage(_ language: String) -> String {
        language.lowercased().hasPrefix("ar") ? "ar" : "en"
    }
}

private enum CartPrescriptionReviewError: LocalizedError {
    case cartIsBusy
    case invalidMedicine
    case maximumItemCountReached(Int)

    var errorDescription: String? {
        switch self {
        case .cartIsBusy:
            return "The cart is still updating. Please try again."
        case .invalidMedicine:
            return "One or more medicines could not be added to the cart."
        case let .maximumItemCountReached(limit):
            return "You can add up to \(limit) items to the cart."
        }
    }
}
