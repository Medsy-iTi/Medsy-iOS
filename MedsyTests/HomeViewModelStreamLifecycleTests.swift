//
//  HomeViewModelStreamLifecycleTests.swift
//  MedsyTests
//
//  Created by Antoneos Philip on 16/08/2026.
//

import Foundation
import SwiftUI
import XCTest
@testable import Medsy

private final class MockGetOfferResultUseCase: GetOfferResultUseCaseProtocol {
    var executeResult: OfferResult?
    var executeCallCount = 0
    var streamYieldValues: [OfferResult] = []

    func execute(requestId: Int) async throws -> OfferResult {
        executeCallCount += 1
        if let res = executeResult {
            return res
        }
        return OfferResult(items: [], totalPrice: 0.0, prescriptionUrl: nil, paymentMethod: nil)
    }

    func stream(requestId: Int) -> AsyncThrowingStream<OfferResult, Error> {
        AsyncThrowingStream { continuation in
            for val in self.streamYieldValues {
                continuation.yield(val)
            }
            continuation.finish()
        }
    }
}

private final class MockOffersRemoteDataSource: OffersRemoteDataSourceProtocol {
    var requestsToReturn: [CompleteRequestResponseDTO] = []
    var ordersToReturn: [MasterOrderDTO] = []

    func getOfferResult(requestId: Int) async throws -> OfferResultResponseDTO {
        OfferResultResponseDTO(items: [], totalPrice: 0, prescriptionUrl: nil)
    }

    func streamOfferResult(requestId: Int) -> AsyncThrowingStream<OfferResultResponseDTO, Error> {
        AsyncThrowingStream { continuation in
            continuation.finish()
        }
    }

    func selectPharmacy(requestId: Int, selectedItems: [ConfirmOfferItemDTO]) async throws -> SelectPharmacyResponseDTO {
        SelectPharmacyResponseDTO(requestId: requestId, offers: [], deliveryFees: 0, totalPrice: 0)
    }

    func selectPharmacy(requestId: Int, selectedRequestItemIds: [Int]) async throws -> SelectPharmacyResponseDTO {
        SelectPharmacyResponseDTO(requestId: requestId, offers: [], deliveryFees: 0, totalPrice: 0)
    }

    func confirmOffer(requestId: Int, fulfillmentMethod: String) async throws -> ConfirmOfferResponseDTO {
        let json = """
        {"masterOrderId": 1, "orderStatus": "PENDING", "paymentMethod": "CASH", "paymentStatus": "UNPAID"}
        """.data(using: .utf8)!
        return try JSONDecoder().decode(ConfirmOfferResponseDTO.self, from: json)
    }

    func fetchMasterOrders(page: Int, size: Int) async throws -> [MasterOrderDTO] {
        ordersToReturn
    }

    func fetchRequest(requestId: Int) async throws -> CompleteRequestResponseDTO {
        requestsToReturn.first ?? CompleteRequestResponseDTO(
            id: requestId,
            customerId: 1,
            customerName: "Test User",
            customerPhone: "01000000000",
            deliveryLatitude: 30.0,
            deliveryLongitude: 31.0,
            deliveryAddress: "Cairo",
            status: "SEARCHING",
            createdAt: ISO8601DateFormatter().string(from: Date()),
            items: [],
            prescriptionUrl: nil,
            notes: nil,
            paymentMethod: "CASH"
        )
    }

    func fetchRequests(page: Int, size: Int) async throws -> [CompleteRequestResponseDTO] {
        requestsToReturn
    }
}

@MainActor
final class HomeViewModelStreamLifecycleTests: XCTestCase {

    func testImmediateRestSnapshotPopulatesOffers() async {
        let mockUseCase = MockGetOfferResultUseCase()
        let mockRemoteDS = MockOffersRemoteDataSource()

        let item = OfferResultItem(
            requestItemId: 1,
            productId: 10,
            productName: "Panadol",
            imageUrl: nil,
            unitPrice: 50.0,
            isAlternative: false,
            isAvailable: true
        )
        mockUseCase.executeResult = OfferResult(items: [item], totalPrice: 50.0, prescriptionUrl: nil, paymentMethod: "CASH")

        let formatter = ISO8601DateFormatter()
        let activeReq = CompleteRequestResponseDTO(
            id: 100,
            customerId: 1,
            customerName: "Test User",
            customerPhone: "01000000000",
            deliveryLatitude: 30.0,
            deliveryLongitude: 31.0,
            deliveryAddress: "Cairo",
            status: "SEARCHING",
            createdAt: formatter.string(from: Date()),
            items: [],
            prescriptionUrl: nil,
            notes: nil,
            paymentMethod: "CASH"
        )
        mockRemoteDS.requestsToReturn = [activeReq]

        let viewModel = HomeViewModel(
            getOfferResultUseCase: mockUseCase,
            offersRemoteDataSource: mockRemoteDS
        )

        await viewModel.refresh()

        XCTAssertEqual(mockUseCase.executeCallCount, 1)
        XCTAssertEqual(viewModel.activeRequestIds, [100])
        XCTAssertEqual(viewModel.selectedStatus, .firstOffer)
        XCTAssertEqual(viewModel.offerTotalPrice, 50.0)
        XCTAssertEqual(viewModel.availableOffersCount, 1)
        XCTAssertFalse(viewModel.isRefreshing)
    }

    func testInactiveScenePhasePreservesOngoingStreams() async {
        let mockUseCase = MockGetOfferResultUseCase()
        let mockRemoteDS = MockOffersRemoteDataSource()

        let formatter = ISO8601DateFormatter()
        let activeReq = CompleteRequestResponseDTO(
            id: 200,
            customerId: 1,
            customerName: "Test User",
            customerPhone: "01000000000",
            deliveryLatitude: 30.0,
            deliveryLongitude: 31.0,
            deliveryAddress: "Cairo",
            status: "SEARCHING",
            createdAt: formatter.string(from: Date()),
            items: [],
            prescriptionUrl: nil,
            notes: nil,
            paymentMethod: "CASH"
        )
        mockRemoteDS.requestsToReturn = [activeReq]

        let viewModel = HomeViewModel(
            getOfferResultUseCase: mockUseCase,
            offersRemoteDataSource: mockRemoteDS
        )

        await viewModel.refresh()
        XCTAssertEqual(viewModel.activeRequestIds, [200])

        // When Screen Recording starts or Control Center is pulled down, scenePhase becomes .inactive
        viewModel.handleScenePhaseChange(to: .inactive)

        // Stream/polling state must NOT be wiped
        XCTAssertEqual(viewModel.activeRequestIds, [200])
        XCTAssertNotEqual(viewModel.selectedStatus, .home)
    }

    func testBackgroundScenePhaseStopsPollingCleanly() async {
        let mockUseCase = MockGetOfferResultUseCase()
        let mockRemoteDS = MockOffersRemoteDataSource()

        let formatter = ISO8601DateFormatter()
        let activeReq = CompleteRequestResponseDTO(
            id: 300,
            customerId: 1,
            customerName: "Test User",
            customerPhone: "01000000000",
            deliveryLatitude: 30.0,
            deliveryLongitude: 31.0,
            deliveryAddress: "Cairo",
            status: "SEARCHING",
            createdAt: formatter.string(from: Date()),
            items: [],
            prescriptionUrl: nil,
            notes: nil,
            paymentMethod: "CASH"
        )
        mockRemoteDS.requestsToReturn = [activeReq]

        let viewModel = HomeViewModel(
            getOfferResultUseCase: mockUseCase,
            offersRemoteDataSource: mockRemoteDS
        )

        await viewModel.refresh()
        viewModel.handleScenePhaseChange(to: .background)

        // App background should stop background task
        viewModel.handleAppBackground()
        // Upon foreground, app active refreshes cleanly
        viewModel.handleAppActive()
        XCTAssertFalse(viewModel.isRefreshing)
    }

    func testScreenCaptureChangeSyncsState() async {
        let mockUseCase = MockGetOfferResultUseCase()
        let mockRemoteDS = MockOffersRemoteDataSource()

        let formatter = ISO8601DateFormatter()
        let activeReq = CompleteRequestResponseDTO(
            id: 400,
            customerId: 1,
            customerName: "Test User",
            customerPhone: "01000000000",
            deliveryLatitude: 30.0,
            deliveryLongitude: 31.0,
            deliveryAddress: "Cairo",
            status: "SEARCHING",
            createdAt: formatter.string(from: Date()),
            items: [],
            prescriptionUrl: nil,
            notes: nil,
            paymentMethod: "CASH"
        )
        mockRemoteDS.requestsToReturn = [activeReq]

        let viewModel = HomeViewModel(
            getOfferResultUseCase: mockUseCase,
            offersRemoteDataSource: mockRemoteDS
        )

        await viewModel.refresh()
        viewModel.handleScreenCaptureChange(isCaptured: true)
        XCTAssertEqual(viewModel.activeRequestIds, [400])
    }
}
