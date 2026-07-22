//
//  CartViewModelTests.swift
//  MedsyTests
//
//  Created by Ahmed Elkady on 19/07/2026.
//

import XCTest
import SwiftUI
@testable import Medsy

@MainActor
final class CartViewModelTests: XCTestCase {
    func testAddingSameProductMergesQuantities() {
        let viewModel = CartViewModel(items: [item(id: "local-1", productID: 10, quantity: 1)])

        let effect = viewModel.handle(.addItem(item(id: "local-2", productID: 10, quantity: 2)))

        XCTAssertEqual(viewModel.itemCount, 3)
        XCTAssertEqual(viewModel.distinctProductCount, 1)
        XCTAssertEqual(loadedItems(from: viewModel).count, 1)
        XCTAssertEqual(effect, .sync)
        XCTAssertEqual(viewModel.feedback, .itemAdded("Medicine"))
        XCTAssertEqual(viewModel.feedbackSequence, 1)
    }

    func testDistinctProductCountCountsRowsNotQuantities() {
        let viewModel = CartViewModel(
            items: [
                item(id: "first", productID: 10, quantity: 3),
                item(id: "second", productID: 20, quantity: 2)
            ]
        )

        XCTAssertEqual(viewModel.itemCount, 5)
        XCTAssertEqual(viewModel.distinctProductCount, 2)
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

    func testPrescriptionsCanBeAddedReplacedAndRemovedIndependently() {
        let viewModel = CartViewModel()
        let firstData = Data([1, 2, 3])
        let secondData = Data([4, 5, 6])
        let replacementData = Data([7, 8, 9])

        XCTAssertEqual(viewModel.handle(.setPrescription(firstData, .camera)), .persistPrescription)
        XCTAssertEqual(viewModel.handle(.setPrescription(secondData, .photoLibrary)), .persistPrescription)
        XCTAssertEqual(viewModel.prescriptions.map(\.imageData), [firstData, secondData])
        XCTAssertTrue(viewModel.hasContent)

        let firstID = viewModel.prescriptions[0].id
        let secondID = viewModel.prescriptions[1].id
        XCTAssertEqual(
            viewModel.handle(
                .replacePrescription(id: firstID, data: replacementData, source: .photoLibrary)
            ),
            .persistPrescription
        )
        XCTAssertEqual(viewModel.prescriptions[0].imageData, replacementData)
        XCTAssertEqual(viewModel.prescriptions[0].source, .photoLibrary)

        XCTAssertEqual(viewModel.handle(.removePrescriptionByID(secondID)), .persistPrescription)
        XCTAssertEqual(viewModel.prescriptions.count, 1)
        XCTAssertTrue(viewModel.hasContent)
    }

    func testContinueRequestIncludesItemsAndPrescription() {
        let cartItem = item(id: "first", productID: 10, quantity: 2)
        let attachment = CartPrescriptionAttachment(
            imageData: Data([1, 2, 3]),
            source: .camera
        )
        let viewModel = CartViewModel(items: [cartItem], prescriptions: [attachment])

        let effect = viewModel.handle(.continueRequest)

        XCTAssertEqual(
            effect,
            .continueRequest(
                CartRequestDraft(
                    items: [cartItem],
                    prescriptions: [attachment]
                )
            )
        )
    }

    func testPrescriptionOnlyCartCanContinue() {
        let attachment = CartPrescriptionAttachment(
            imageData: Data([1, 2, 3]),
            source: .photoLibrary
        )
        let viewModel = CartViewModel(prescriptions: [attachment])

        XCTAssertNotNil(viewModel.handle(.continueRequest))
    }

    func testClearingCartRemovesItemsAndPrescription() {
        let attachment = CartPrescriptionAttachment(
            imageData: Data([1, 2, 3]),
            source: .camera
        )
        let viewModel = CartViewModel(
            items: [item(id: "first", productID: 10, quantity: 2)],
            prescriptions: [attachment]
        )

        XCTAssertEqual(viewModel.handle(.clear), .sync)
        XCTAssertEqual(viewModel.state, .empty)
        XCTAssertTrue(viewModel.prescriptions.isEmpty)
        XCTAssertFalse(viewModel.hasContent)
    }

    func testRealProductMappingAddsProductDataAndSynchronizesQuantity() {
        let product = MedsyProduct(
            id: "42",
            name: "Real Product",
            dosageInfo: "500 mg",
            price: 75,
            imageUrl: "https://example.com/product.png",
            badgeText: "Company",
            badgeColor: .green,
            categoryName: "Category"
        )
        let viewModel = CartViewModel()

        viewModel.handle(.addItem(CartItemPresentationMapper.map(product)))
        viewModel.handle(.addItem(CartItemPresentationMapper.map(product)))

        let cartItem = loadedItems(from: viewModel).first
        XCTAssertEqual(cartItem?.productID, 42)
        XCTAssertEqual(cartItem?.name, "Real Product")
        XCTAssertEqual(cartItem?.dosageInfo, "500 mg")
        XCTAssertEqual(cartItem?.unitPrice, 75)
        XCTAssertEqual(cartItem?.imageUrl, "https://example.com/product.png")
        XCTAssertEqual(viewModel.quantity(forProductID: 42), 2)
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
