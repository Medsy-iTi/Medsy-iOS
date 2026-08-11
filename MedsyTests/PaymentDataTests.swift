//
//  PaymentDataTests.swift
//  MedsyTests
//
//  Created by Ahmed Elkady on 11/08/2026.
//

import Alamofire
import XCTest
@testable import Medsy

final class PaymentDataTests: XCTestCase {
    func testMasterOrderMapperMapsBackendPaymentContract() {
        let dto = MasterOrderPaymentDTO(
            id: 44,
            paymentMethod: "CARD",
            paymentStatus: "CANCELED",
            orderStatus: "CANCELLED",
            paymentExpiresAt: "2026-08-11T22:45:30.123456",
            paidAt: nil
        )

        let result = PaymentMapper.map(dto)

        XCTAssertEqual(result.id, 44)
        XCTAssertEqual(result.paymentMethod, .card)
        XCTAssertEqual(result.paymentStatus, .cancelled)
        XCTAssertEqual(result.orderStatus, .cancelled)
        XCTAssertNotNil(result.paymentExpiresAt)
        XCTAssertNil(result.paidAt)
    }

    func testPaymentIntentMapperPreservesStripeValues() {
        let result = PaymentMapper.map(
            PaymentIntentDTO(
                paymentIntentId: "pi_test",
                clientSecret: "pi_test_secret"
            )
        )

        XCTAssertEqual(
            result,
            PaymentIntent(id: "pi_test", clientSecret: "pi_test_secret")
        )
    }

    func testCreateIntentEndpointUsesMasterOrderIdBody() throws {
        let endpoint = PaymentEndpoint.createIntent(
            CreatePaymentIntentRequestDTO(orderId: 91)
        )

        XCTAssertEqual(endpoint.path, "payments/create-intent")
        XCTAssertEqual(endpoint.method, .post)
        XCTAssertTrue(endpoint.requiresAuthentication)

        let body = try XCTUnwrap(endpoint.body)
        let decoded = try JSONDecoder().decode([String: Int].self, from: body)
        XCTAssertEqual(decoded, ["orderId": 91])
    }

    func testRemoteDataSourceFetchesMasterOrderEndpoint() async throws {
        let response = MasterOrderPaymentResponseDTO(
            success: true,
            message: "Master Order fetched",
            data: MasterOrderPaymentDTO(
                id: 15,
                paymentMethod: "CARD",
                paymentStatus: "PENDING",
                orderStatus: "PENDING_PAYMENT",
                paymentExpiresAt: nil,
                paidAt: nil
            )
        )
        let networkService = PaymentNetworkServiceSpy(response: response)
        let dataSource = PaymentRemoteDataSource(networkService: networkService)

        let result = try await dataSource.fetchMasterOrderPayment(masterOrderId: 15)

        XCTAssertEqual(result.id, 15)
        XCTAssertEqual(networkService.capturedPath, "masterorders/15")
        XCTAssertEqual(networkService.capturedMethod, .get)
    }

    func testRepositoryMapsRemotePaymentIntent() async throws {
        let remoteDataSource = PaymentRemoteDataSourceSpy(
            paymentIntent: PaymentIntentDTO(
                paymentIntentId: "pi_17",
                clientSecret: "pi_17_secret"
            )
        )
        let repository = PaymentRepository(remoteDataSource: remoteDataSource)

        let result = try await repository.createPaymentIntent(masterOrderId: 17)

        XCTAssertEqual(result, PaymentIntent(id: "pi_17", clientSecret: "pi_17_secret"))
        XCTAssertEqual(remoteDataSource.createdIntentMasterOrderIds, [17])
    }

    func testOfferSelectionEndpointMatchesCurrentBackendContract() throws {
        let endpoint = OffersEndpoint.selectOffer(
            requestId: 12,
            body: ConfirmOfferRequestDTO(
                selectedItems: [
                    ConfirmOfferSelectionDTO(requestItemId: 3, productId: 99)
                ]
            )
        )

        XCTAssertEqual(endpoint.path, "requests/12/select")
        let body = try XCTUnwrap(endpoint.body)
        let json = try XCTUnwrap(
            JSONSerialization.jsonObject(with: body) as? [String: Any]
        )
        let selectedItems = try XCTUnwrap(json["selectedItems"] as? [[String: Int]])
        XCTAssertEqual(selectedItems, [["requestItemId": 3, "productId": 99]])
    }

    func testFulfillmentConfirmationMapsMasterOrderPaymentState() throws {
        let selectionJSON = try XCTUnwrap("""
        {
          "requestId": 12,
          "offers": [
            {
              "offerId": 71,
              "pharmacyId": 8,
              "pharmacyName": "Medsy Pharmacy",
              "items": []
            }
          ],
          "deliveryFees": 10,
          "totalPrice": 120
        }
        """.data(using: .utf8))
        let selection = try JSONDecoder().decode(ConfirmOfferResponseDTO.self, from: selectionJSON)
        let data = ConfirmOfferDataDTO(
            selection: selection,
            fulfillment: FulfillmentConfirmationResponseDTO(
                masterOrderId: 501,
                orderStatus: "PENDING_PAYMENT",
                paymentMethod: "CARD",
                paymentStatus: "PENDING"
            ),
            selectedRequestItemIds: [3]
        )

        let result = OfferResultMapper.map(data)

        XCTAssertEqual(result.masterOrderId, 501)
        XCTAssertEqual(result.orderStatus, .pendingPayment)
        XCTAssertEqual(result.paymentMethod, .card)
        XCTAssertEqual(result.paymentStatus, .pending)
        XCTAssertEqual(result.orders.first?.itemIds, [3])
    }
}

private enum PaymentDataTestError: Error {
    case invalidResponseType
}

private final class PaymentNetworkServiceSpy: NetworkServiceProtocol {
    private let response: Any
    private(set) var capturedPath: String?
    private(set) var capturedMethod: HTTPMethod?

    init(response: Any) {
        self.response = response
    }

    func request<T: Decodable>(endpoint: ApiEndpoint) async throws -> T {
        capturedPath = endpoint.path
        capturedMethod = endpoint.method
        guard let response = response as? T else {
            throw PaymentDataTestError.invalidResponseType
        }
        return response
    }

    func requestData(endpoint: ApiEndpoint) async throws -> Data {
        capturedPath = endpoint.path
        capturedMethod = endpoint.method
        throw PaymentDataTestError.invalidResponseType
    }
}

private final class PaymentRemoteDataSourceSpy: PaymentRemoteDataSourceProtocol {
    private(set) var createdIntentMasterOrderIds: [Int] = []
    private let paymentIntent: PaymentIntentDTO

    init(paymentIntent: PaymentIntentDTO) {
        self.paymentIntent = paymentIntent
    }

    func fetchMasterOrderPayment(masterOrderId: Int) async throws -> MasterOrderPaymentDTO {
        throw PaymentDataTestError.invalidResponseType
    }

    func createPaymentIntent(masterOrderId: Int) async throws -> PaymentIntentDTO {
        createdIntentMasterOrderIds.append(masterOrderId)
        return paymentIntent
    }
}
