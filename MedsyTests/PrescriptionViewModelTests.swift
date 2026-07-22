//
//  PrescriptionViewModelTests.swift
//  MedsyTests
//
//  Created by Ahmed Elkady on 22/07/2026.
//

import XCTest
@testable import Medsy

@MainActor
final class PrescriptionViewModelTests: XCTestCase {
    func testNeedsReviewMedicineBlocksAddingUntilConfirmed() {
        let needsReview = medicine(confidence: .needsReview, isConfirmed: false)
        let viewModel = PrescriptionViewModel(initialMedicines: [recognizedMedicine(), needsReview])

        XCTAssertFalse(viewModel.canAddToCart)
        XCTAssertEqual(viewModel.confirmedMedicineCount, 1)
        XCTAssertEqual(viewModel.needsReviewMedicineCount, 1)

        viewModel.handle(.confirmMedicine(needsReview.id))

        XCTAssertTrue(viewModel.canAddToCart)
        XCTAssertEqual(viewModel.confirmedMedicineCount, 2)
        XCTAssertEqual(viewModel.needsReviewMedicineCount, 0)
    }

    func testReplacingMedicineMarksItRecognizedAndConfirmed() {
        let unclearMedicine = medicine(confidence: .needsReview, isConfirmed: false)
        let viewModel = PrescriptionViewModel(initialMedicines: [unclearMedicine])
        let replacement = MedsyProduct(
            id: "42",
            name: "Replacement",
            dosageInfo: "20 tablets",
            price: 55,
            imageUrl: nil,
            badgeText: "Company",
            badgeColor: .green,
            categoryName: "Pain relief"
        )

        viewModel.handle(.replaceMedicine(unclearMedicine.id, replacement))

        XCTAssertEqual(viewModel.medicines.first?.name, "Replacement")
        XCTAssertEqual(viewModel.medicines.first?.price, "55 EGP")
        XCTAssertTrue(viewModel.medicines.first?.isConfirmed == true)
        XCTAssertTrue(viewModel.canAddToCart)
    }

    func testQuantityStepperNeverDropsBelowOne() {
        let item = recognizedMedicine()
        let viewModel = PrescriptionViewModel(initialMedicines: [item])

        viewModel.handle(.increaseQuantity(item.id))
        viewModel.handle(.decreaseQuantity(item.id))
        viewModel.handle(.decreaseQuantity(item.id))

        XCTAssertEqual(viewModel.medicines.first?.quantity, 1)
    }

    func testDeletingLastMedicineShowsNoMedicinesResult() {
        let item = recognizedMedicine()
        let viewModel = PrescriptionViewModel(initialMedicines: [item])

        viewModel.handle(.deleteMedicine(item.id))

        XCTAssertTrue(viewModel.medicines.isEmpty)
        XCTAssertEqual(viewModel.state, .result(.noMedicines))
    }

    private func recognizedMedicine() -> PrescriptionMedicineDisplay {
        medicine(confidence: .identified, isConfirmed: true)
    }

    private func medicine(
        confidence: PrescriptionMedicineConfidence,
        isConfirmed: Bool
    ) -> PrescriptionMedicineDisplay {
        PrescriptionMedicineDisplay(
            name: "Medicine",
            details: "20 tablets",
            price: "20 EGP",
            confidence: confidence,
            isConfirmed: isConfirmed
        )
    }
}
