//
//  CompleteRequestViewModelTests.swift
//  MedsyTests
//
//  Created by Ehab Salah on 24/07/2026.
//

import Foundation
import XCTest
@testable import Medsy

@MainActor
final class CompleteRequestViewModelTests: XCTestCase {
    func testDefaultsToDeliveryAndCash() {
        let viewModel = makeViewModel()

        XCTAssertEqual(viewModel.receiveMethod, .delivery)
        XCTAssertEqual(viewModel.paymentMethod, .cash)
        XCTAssertTrue(viewModel.showsDeliveryDetails)
        XCTAssertFalse(viewModel.showsVisaForm)
    }

    func testPickupDoesNotCallDeliveryRequestEndpoint() async {
        var capturedSubmission: CompleteRequestSubmission?
        let submitUseCase = CompleteRequestSubmitUseCaseFake()
        let viewModel = makeViewModel(submitUseCase: submitUseCase) { submission in
            capturedSubmission = submission
            return true
        }

        viewModel.selectReceiveMethod(.pickup)
        let succeeded = await viewModel.submit()

        XCTAssertFalse(succeeded)
        XCTAssertFalse(viewModel.showsDeliveryDetails)
        XCTAssertNil(capturedSubmission)
        XCTAssertTrue(viewModel.validationErrors.contains(.pickupUnsupported))
        XCTAssertEqual(submitUseCase.inputs.count, 0)
    }

    func testSavedProfileAddressIsUsedOnlyWithValidCoordinates() async {
        let profile = CustomerProfile(
            id: 1,
            email: "patient@example.com",
            firstName: "Patient",
            lastName: "Name",
            homeAddress: "Tahrir Square, Cairo",
            dateOfBirth: nil,
            homeLatitude: 30.0444,
            homeLongitude: 31.2357,
            phoneNumber: "01000000000"
        )
        let viewModel = makeViewModel(profile: profile)

        await viewModel.loadSavedAddress()

        XCTAssertEqual(
            viewModel.deliveryLocation,
            CompleteRequestLocation(
                address: "Tahrir Square, Cairo",
                latitude: 30.0444,
                longitude: 31.2357
            )
        )
    }

    func testSavedProfileWithoutUsableCoordinatesRequiresMapConfirmation() async {
        let profile = CustomerProfile(
            id: 1,
            email: "patient@example.com",
            firstName: "Patient",
            lastName: "Name",
            homeAddress: "Cairo",
            dateOfBirth: nil,
            homeLatitude: 0,
            homeLongitude: 0,
            phoneNumber: "01000000000"
        )
        let viewModel = makeViewModel(profile: profile)

        await viewModel.loadSavedAddress()
        let succeeded = await viewModel.submit()

        XCTAssertEqual(viewModel.savedAddress, "Cairo")
        XCTAssertNil(viewModel.deliveryLocation)
        XCTAssertFalse(succeeded)
        XCTAssertTrue(viewModel.validationErrors.contains(.locationRequired))
    }

    func testValidVisaSubmitsOnlyNonSensitivePaymentSelection() async {
        var capturedSubmission: CompleteRequestSubmission?
        let submitUseCase = CompleteRequestSubmitUseCaseFake()
        let viewModel = makeViewModel(submitUseCase: submitUseCase) { submission in
            capturedSubmission = submission
            return true
        }
        viewModel.confirmLocation(validLocation)
        viewModel.selectPaymentMethod(.visa)
        viewModel.cardholderName = "Ehab Salah"
        viewModel.cardNumber = "4111 1111 1111 1111"
        viewModel.expiry = "12/30"
        viewModel.cvv = "123"

        let succeeded = await viewModel.submit()

        XCTAssertTrue(succeeded)
        XCTAssertEqual(capturedSubmission?.paymentMethod, .visa)
        XCTAssertEqual(capturedSubmission?.deliveryLocation, validLocation)
        XCTAssertEqual(capturedSubmission?.itemCount, 2)
        XCTAssertEqual(submitUseCase.inputs, [
            SubmitCompleteRequestInput(
                deliveryLatitude: validLocation.latitude,
                deliveryLongitude: validLocation.longitude,
                deliveryAddress: validLocation.address
            )
        ])
        XCTAssertEqual(viewModel.submittedRequest?.id, 50)
    }

    func testInvalidVisaReportsImportantFieldErrors() async {
        let viewModel = makeViewModel()
        viewModel.confirmLocation(validLocation)
        viewModel.selectPaymentMethod(.visa)
        viewModel.cardholderName = ""
        viewModel.cardNumber = "4000 0000 0000 0000"
        viewModel.expiry = "01/20"
        viewModel.cvv = "12"

        let succeeded = await viewModel.submit()

        XCTAssertFalse(succeeded)
        XCTAssertEqual(
            Set(viewModel.validationErrors),
            Set([
                .cardholderNameRequired,
                .invalidCardNumber,
                .invalidExpiry,
                .invalidCVV
            ])
        )
    }

    func testSubmissionFailureKeepsCheckoutStateAndShowsError() async {
        let viewModel = makeViewModel { _ in false }
        viewModel.confirmLocation(validLocation)

        let succeeded = await viewModel.submit()

        XCTAssertFalse(succeeded)
        XCTAssertNotNil(viewModel.submissionErrorMessage)
        XCTAssertEqual(viewModel.deliveryLocation, validLocation)
        XCTAssertNotNil(viewModel.submittedRequest)
    }

    func testRetryAfterCartCleanupFailureDoesNotCreateDuplicateRequest() async {
        var cleanupAttempts = 0
        let submitUseCase = CompleteRequestSubmitUseCaseFake()
        let viewModel = makeViewModel(submitUseCase: submitUseCase) { _ in
            cleanupAttempts += 1
            return cleanupAttempts == 2
        }
        viewModel.confirmLocation(validLocation)

        let firstSucceeded = await viewModel.submit()
        let retrySucceeded = await viewModel.submit()

        XCTAssertFalse(firstSucceeded)
        XCTAssertTrue(retrySucceeded)
        XCTAssertEqual(cleanupAttempts, 2)
        XCTAssertEqual(submitUseCase.inputs.count, 1)
    }

    func testBackendFailureMessageIsPresented() async {
        let message = "A request cannot be created from an empty cart"
        let submitUseCase = CompleteRequestSubmitUseCaseFake(
            result: .failure(NetworkError.validationError(message))
        )
        let viewModel = makeViewModel(submitUseCase: submitUseCase)
        viewModel.confirmLocation(validLocation)

        let succeeded = await viewModel.submit()

        XCTAssertFalse(succeeded)
        XCTAssertEqual(viewModel.submissionErrorMessage, message)
        XCTAssertNil(viewModel.submittedRequest)
    }

    func testDuplicateSubmissionIsRejectedWhileFirstSubmissionIsRunning() async {
        let viewModel = makeViewModel { _ in
            try? await Task.sleep(for: .milliseconds(50))
            return true
        }
        viewModel.confirmLocation(validLocation)

        let firstSubmission = Task { await viewModel.submit() }
        await Task.yield()
        let duplicateSucceeded = await viewModel.submit()
        let firstSucceeded = await firstSubmission.value

        XCTAssertFalse(duplicateSucceeded)
        XCTAssertTrue(firstSucceeded)
    }

    func testCartDraftMapperPreservesRequestSummary() {
        let cartDraft = CartRequestDraft(
            items: [
                CartDisplayItem(
                    id: "item-1",
                    productID: 10,
                    name: "Medicine",
                    dosageInfo: "500 mg",
                    unitPrice: 25,
                    quantity: 2,
                    imageUrl: "https://example.com/medicine.jpg"
                )
            ],
            prescriptions: [
                CartPrescriptionAttachment(imageData: Data([1]), source: .camera)
            ]
        )

        let result = CompleteRequestDraftMapper.map(cartDraft)

        XCTAssertEqual(result.itemCount, 2)
        XCTAssertEqual(result.prescriptionCount, 1)
        XCTAssertEqual(result.estimatedTotal, 50)
        XCTAssertEqual(result.items.first?.name, "Medicine")
        XCTAssertEqual(result.items.first?.imageURL, "https://example.com/medicine.jpg")
    }

    private var validLocation: CompleteRequestLocation {
        CompleteRequestLocation(
            address: "Tahrir Square, Cairo",
            latitude: 30.0444,
            longitude: 31.2357
        )
    }

    private func makeViewModel(
        profile: CustomerProfile? = nil,
        submitUseCase: CompleteRequestSubmitUseCaseFake = CompleteRequestSubmitUseCaseFake(),
        onSubmit: @escaping (CompleteRequestSubmission) async -> Bool = { _ in true }
    ) -> CompleteRequestViewModel {
        CompleteRequestViewModel(
            draft: CompleteRequestDraft(
                items: [
                    CompleteRequestItem(
                        id: "item-1",
                        name: "Medicine",
                        dosageInfo: "500 mg",
                        unitPrice: 25,
                        quantity: 2
                    )
                ],
                prescriptionCount: 0
            ),
            getCustomerProfileUseCase: CompleteRequestProfileUseCaseFake(profile: profile),
            submitCompleteRequestUseCase: submitUseCase,
            now: {
                Calendar(identifier: .gregorian).date(
                    from: DateComponents(year: 2026, month: 7, day: 24)
                )!
            },
            onRequestCreated: onSubmit
        )
    }
}

private final class CompleteRequestProfileUseCaseFake: GetCustomerProfileUseCaseProtocol {
    let profile: CustomerProfile?

    init(profile: CustomerProfile?) {
        self.profile = profile
    }

    func execute() async throws -> CustomerProfile {
        guard let profile else {
            throw CompleteRequestProfileUseCaseFakeError.missingProfile
        }
        return profile
    }
}

private enum CompleteRequestProfileUseCaseFakeError: Error {
    case missingProfile
}

private final class CompleteRequestSubmitUseCaseFake: SubmitCompleteRequestUseCaseProtocol {
    private(set) var inputs: [SubmitCompleteRequestInput] = []
    let result: Result<SubmittedMedicineRequest, Error>

    init(
        result: Result<SubmittedMedicineRequest, Error> = .success(
            SubmittedMedicineRequest(
                id: 50,
                customerID: 12,
                deliveryLatitude: 30.0444,
                deliveryLongitude: 31.2357,
                deliveryAddress: "Tahrir Square, Cairo",
                status: "PENDING",
                createdAt: Date(timeIntervalSince1970: 0),
                items: []
            )
        )
    ) {
        self.result = result
    }

    func execute(input: SubmitCompleteRequestInput) async throws -> SubmittedMedicineRequest {
        inputs.append(input)
        return try result.get()
    }
}
