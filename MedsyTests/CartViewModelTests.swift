//
//  CartViewModelTests.swift
//  MedsyTests
//
//  Created by Ahmed Elkady on 19/07/2026.
//

import XCTest
@testable import Medsy

@MainActor
final class CartViewModelTests: XCTestCase {
    func testAddingSameProductMergesQuantities() {
        let viewModel = CartViewModel(items: [item(id: "local-1", productID: 10, quantity: 1)])

        let effect = viewModel.handle(.addItem(item(id: "local-2", productID: 10, quantity: 2)))

        XCTAssertEqual(viewModel.itemCount, 3)
        XCTAssertEqual(loadedItems(from: viewModel).count, 1)
        XCTAssertEqual(effect, .sync)
    }

    func testDecreasingLastQuantityRemovesItemAndUndoRestoresIt() {
        let viewModel = CartViewModel(items: [item(id: "first", productID: 10, quantity: 1)])

        XCTAssertEqual(viewModel.handle(.decreaseQuantity(itemID: "first")), .sync)
        XCTAssertEqual(viewModel.state, .empty)
        XCTAssertEqual(viewModel.removedItem?.id, "first")

        XCTAssertEqual(viewModel.handle(.undoRemoval), .sync)
        XCTAssertEqual(loadedItems(from: viewModel).map(\.id), ["first"])
        XCTAssertNil(viewModel.removedItem)
    }

    func testMaximumItemCountRejectsMutation() {
        let viewModel = CartViewModel(
            items: [item(id: "first", productID: 10, quantity: 20)],
            maximumItemCount: 20
        )

        let effect = viewModel.handle(.increaseQuantity(itemID: "first"))

        XCTAssertNil(effect)
        XCTAssertEqual(viewModel.itemCount, 20)
        XCTAssertEqual(viewModel.feedback, .maximumItemCountReached(20))
    }

    func testSyncFailureKeepsCachedItemsVisible() {
        let cachedItem = item(id: "cached", productID: 10, quantity: 2)
        let viewModel = CartViewModel(items: [cachedItem])

        viewModel.handle(.syncFailed("Offline"))

        XCTAssertEqual(loadedItems(from: viewModel), [cachedItem])
        XCTAssertEqual(viewModel.syncState, .failed("Offline"))
    }

    func testServerSyncReconcilesLocalCart() {
        let viewModel = CartViewModel(items: [item(id: "local", productID: 10, quantity: 1)])
        let serverItem = item(id: "server", productID: 20, quantity: 3)

        viewModel.handle(.syncSucceeded([serverItem]))

        XCTAssertEqual(loadedItems(from: viewModel), [serverItem])
        XCTAssertEqual(viewModel.syncState, .synced)
        XCTAssertEqual(viewModel.estimatedTotal, 30)
    }

    func testPrescriptionCanBeAddedReplacedAndRemoved() {
        let viewModel = CartViewModel()
        let firstData = Data([1, 2, 3])
        let replacementData = Data([4, 5, 6])

        XCTAssertEqual(viewModel.handle(.setPrescription(firstData, .camera)), .persistPrescription)
        XCTAssertEqual(viewModel.prescription?.imageData, firstData)
        XCTAssertEqual(viewModel.prescription?.source, .camera)
        XCTAssertTrue(viewModel.hasContent)

        XCTAssertEqual(viewModel.handle(.setPrescription(replacementData, .photoLibrary)), .persistPrescription)
        XCTAssertEqual(viewModel.prescription?.imageData, replacementData)
        XCTAssertEqual(viewModel.prescription?.source, .photoLibrary)

        XCTAssertEqual(viewModel.handle(.removePrescription), .persistPrescription)
        XCTAssertNil(viewModel.prescription)
        XCTAssertFalse(viewModel.hasContent)
    }

    func testContinueRequestIncludesItemsAndPrescription() {
        let cartItem = item(id: "first", productID: 10, quantity: 2)
        let attachment = CartPrescriptionAttachment(
            imageData: Data([1, 2, 3]),
            source: .camera
        )
        let viewModel = CartViewModel(items: [cartItem], prescription: attachment)

        let effect = viewModel.handle(.continueRequest)

        XCTAssertEqual(
            effect,
            .continueRequest(
                CartRequestDraft(
                    items: [cartItem],
                    prescription: attachment
                )
            )
        )
    }

    func testPrescriptionOnlyCartCanContinue() {
        let attachment = CartPrescriptionAttachment(
            imageData: Data([1, 2, 3]),
            source: .photoLibrary
        )
        let viewModel = CartViewModel(prescription: attachment)

        XCTAssertNotNil(viewModel.handle(.continueRequest))
    }

    private func item(id: String, productID: Int64, quantity: Int) -> CartDisplayItem {
        CartDisplayItem(
            id: id,
            productID: productID,
            cartItemID: nil,
            name: "Medicine",
            dosageInfo: "10 tablets",
            unitPrice: 10,
            quantity: quantity,
            imageUrl: nil
        )
    }

    private func loadedItems(from viewModel: CartViewModel) -> [CartDisplayItem] {
        guard case let .loaded(items) = viewModel.state else { return [] }
        return items
    }
}
