//
//  OrdersFeatureTests.swift
//  MedsyTests
//
//  Created by Codex on 21/07/2026.
//

import XCTest
@testable import Medsy

final class OrdersFeatureTests: XCTestCase {
    func testBackendPaginationKeysAreDecoded() throws {
        let data = Data(
            """
            {
              "content": [],
              "pageNumber": 2,
              "pageSize": 20,
              "totalElements": 45,
              "totalPages": 3,
              "last": true
            }
            """.utf8
        )

        let page = try JSONDecoder().decode(PageDTO<MasterOrderDTO>.self, from: data)

        XCTAssertEqual(page.number, 2)
        XCTAssertEqual(page.size, 20)
        XCTAssertEqual(page.totalElements, 45)
        XCTAssertEqual(page.totalPages, 3)
        XCTAssertEqual(page.last, true)
    }

    func testMasterOrdersAndNestedProductsAreMapped() throws {
        let data = Data(
            """
            {
              "success": true,
              "message": "Orders retrieved successfully",
              "data": {
                "content": [
                  {
                    "requestId": 41,
                    "id": 501,
                    "orderResponses": [
                      {
                        "offerId": 71,
                        "pharmacyId": 3,
                        "pharmacyName": "Medsy Pharmacy",
                        "latitude": 30.0,
                        "longitude": 31.0,
                        "items": [
                          {
                            "id": 11,
                            "productId": 12,
                            "quantity": 2,
                            "unitPrice": 42.5,
                            "totalPrice": 85,
                            "product": {
                              "id": 12,
                              "name": "Medicine",
                              "productName": "Received medicine",
                              "imageUrl": "https://example.com/medicine.png"
                            }
                          }
                        ]
                      }
                    ],
                    "paymentMethod": "CARD",
                    "paymentStatus": "PENDING",
                    "fulfillmentMethod": "DELIVERY",
                    "deliveryFee": 10,
                    "totalPrice": 95,
                    "orderStatus": "PENDING_PAYMENT",
                    "paymentExpiresAt": "2026-08-04T12:15:00",
                    "paidAt": null
                  }
                ],
                "pageNumber": 0,
                "pageSize": 20,
                "totalElements": 1,
                "totalPages": 1,
                "last": true
              }
            }
            """.utf8
        )

        let response = try JSONDecoder().decode(OrdersPageResponseDTO.self, from: data)
        let page = try XCTUnwrap(response.data)
        let result = OrderMapper.mapToPagedResult(page)
        let order = try XCTUnwrap(page.content.first)
        let detail = OrderMapper.mapToDetailEntity(order)

        XCTAssertEqual(page.content.first?.requestId, 41)
        XCTAssertEqual(result.items.map(\.id), [501])
        XCTAssertEqual(result.items.first?.itemImageURLs, ["https://example.com/medicine.png"])
        XCTAssertEqual(detail.items.first?.productName, "Received medicine")
        XCTAssertEqual(detail.items.first?.imageURL, "https://example.com/medicine.png")
        XCTAssertEqual(detail.itemsSubtotal, 85)
        XCTAssertEqual(detail.totalPrice, 95)
        XCTAssertEqual(detail.paymentMethod, .card)
        XCTAssertEqual(detail.paymentStatus, .pending)
    }

    func testOrdersEndpointUsesOnlySupportedPaginationParameters() {
        let parameters = OrdersEndpoint
            .fetchOrders(page: 1, size: 20)
            .queryParameters

        XCTAssertEqual(parameters?["page"] as? Int, 1)
        XCTAssertEqual(parameters?["size"] as? Int, 20)
        XCTAssertNil(parameters?["sort"])
        XCTAssertNil(parameters?["status"])
        XCTAssertNil(parameters?["dateFrom"])
        XCTAssertNil(parameters?["dateTo"])
        XCTAssertEqual(OrdersEndpoint.fetchOrders(page: 1, size: 20).path, "masterorders")
    }

    func testBackendOrderStatusesMapToKnownCases() {
        XCTAssertEqual(OrderStatus(rawValue: "PREPARING").rawValue, "PREPARING")
        XCTAssertEqual(OrderStatus(rawValue: "READY_FOR_PICKUP").rawValue, "READY_FOR_PICKUP")
        XCTAssertEqual(OrderStatus(rawValue: "OUT_FOR_DELIVERY").rawValue, "OUT_FOR_DELIVERY")
    }

    func testDetailUsesPaidSnapshotAndAlternativeMetadata() throws {
        let dto = try decodeOrder(
            fulfillmentType: "DELIVERY",
            deliveryFee: 10,
            totalPrice: 95
        )

        let detail = OrderMapper.mapToDetailEntity(dto)

        XCTAssertEqual(detail.itemsSubtotal, 85)
        XCTAssertEqual(detail.deliveryFee, 10)
        XCTAssertEqual(detail.totalPrice, 95)
        XCTAssertEqual(detail.items.first?.unitPrice, 42.5)
        XCTAssertEqual(detail.items.first?.productName, "Received medicine")
        XCTAssertEqual(detail.items.first?.originalProductName, "Requested medicine")
    }

    func testPickupOrderNeverDisplaysDeliveryFeeRow() throws {
        let dto = try decodeOrder(
            fulfillmentType: "PICKUP",
            deliveryFee: 10,
            totalPrice: 85
        )

        let detail = OrderMapper.mapToDetailEntity(dto)

        XCTAssertEqual(detail.fulfillmentType, .pickup)
        XCTAssertNil(detail.deliveryFee)
    }

    @MainActor
    func testHistoryLoadsMoreThanTwentyOrdersUsingNextPage() async throws {
        let firstPage = (1...20).map(orderEntity)
        let secondPage = [orderEntity(id: 21)]
        let useCase = OrdersUseCaseStub(
            pages: [
                0: PagedResult(
                    items: firstPage,
                    page: 0,
                    size: 20,
                    totalElements: 21,
                    totalPages: 2,
                    isLast: false
                ),
                1: PagedResult(
                    items: secondPage,
                    page: 1,
                    size: 20,
                    totalElements: 21,
                    totalPages: 2,
                    isLast: true
                )
            ]
        )
        let viewModel = OrderHistoryViewModel(loadOrdersUseCase: useCase)

        viewModel.handle(.load)
        try await waitUntil { self.orderCount(in: viewModel.historyState) == 20 }

        viewModel.handle(.loadNextPage)
        try await waitUntil { self.orderCount(in: viewModel.historyState) == 21 }

        let requestedPages = await useCase.requestedPages
        XCTAssertEqual(requestedPages, [0, 1])
    }

    @MainActor
    func testPendingCardOrderBeforeExpiryCanPayNow() async throws {
        let viewModel = makeOrderDetailViewModel(
            paymentStatus: .pending,
            expiresAt: Date(timeIntervalSince1970: 2_000)
        )

        viewModel.handle(.load(orderId: 501))
        try await waitUntil { viewModel.paymentAction == .payNow }

        XCTAssertEqual(viewModel.paymentAction, .payNow)
    }

    @MainActor
    func testFailedCardOrderBeforeExpiryCanRetry() async throws {
        let viewModel = makeOrderDetailViewModel(
            paymentStatus: .failed,
            expiresAt: Date(timeIntervalSince1970: 2_000)
        )

        viewModel.handle(.load(orderId: 501))
        try await waitUntil { viewModel.paymentAction == .retry }

        XCTAssertEqual(viewModel.paymentAction, .retry)
    }

    @MainActor
    func testExpiredCardOrderCannotPay() async throws {
        let viewModel = makeOrderDetailViewModel(
            paymentStatus: .pending,
            expiresAt: Date(timeIntervalSince1970: 999)
        )

        viewModel.handle(.load(orderId: 501))
        try await waitForLoadedState(in: viewModel)

        XCTAssertEqual(viewModel.paymentAction, .expired)
    }

    @MainActor
    func testCancelledOrderCannotPay() async throws {
        let viewModel = makeOrderDetailViewModel(
            status: .cancelled,
            paymentStatus: .pending,
            expiresAt: Date(timeIntervalSince1970: 2_000)
        )

        viewModel.handle(.load(orderId: 501))
        try await waitForLoadedState(in: viewModel)

        XCTAssertNil(viewModel.paymentAction)
    }

    @MainActor
    func testCashOrderDoesNotShowPaymentAction() async throws {
        let viewModel = makeOrderDetailViewModel(
            paymentMethod: .cash,
            paymentStatus: .unknown,
            expiresAt: nil
        )

        viewModel.handle(.load(orderId: 501))
        try await waitForLoadedState(in: viewModel)

        XCTAssertNil(viewModel.paymentAction)
    }

    private func decodeOrder(
        fulfillmentType: String,
        deliveryFee: Double,
        totalPrice: Double
    ) throws -> OrderDTO {
        let json =
            """
            {
              "id": 7,
              "userId": 2,
              "pharmacyId": 3,
              "pharmacistId": 4,
              "offerId": 5,
              "totalPrice": \(totalPrice),
              "deliveryLatitude": 30.0,
              "deliveryLongitude": 31.0,
              "status": "DELIVERED",
              "date": "2026-07-20",
              "pharmacyName": "Snapshot Pharmacy",
              "fulfillmentType": "\(fulfillmentType)",
              "deliveryFee": \(deliveryFee),
              "itemsSubtotal": 85,
              "items": [
                {
                  "id": 11,
                  "productId": 12,
                  "quantity": 2,
                  "unitPrice": 42.5,
                  "productName": "Received medicine",
                  "originalProductName": "Requested medicine"
                }
              ]
            }
            """

        return try JSONDecoder().decode(OrderDTO.self, from: Data(json.utf8))
    }

    private func orderEntity(id: Int) -> OrderEntity {
        OrderEntity(
            id: id,
            orderNumber: id,
            pharmacyName: "Pharmacy",
            status: .delivered,
            fulfillmentType: .pickup,
            date: Date(timeIntervalSince1970: TimeInterval(id)),
            totalPrice: 10,
            itemCount: 1,
            itemImageURLs: []
        )
    }

    @MainActor
    private func makeOrderDetailViewModel(
        status: OrderStatus = .pending,
        paymentMethod: MasterOrderPaymentMethod = .card,
        paymentStatus: MasterOrderPaymentStatus,
        expiresAt: Date?
    ) -> OrderDetailViewModel {
        let entity = OrderDetailEntity(
            id: 501,
            orderNumber: 501,
            pharmacyName: "Medsy Pharmacy",
            pharmacyId: 3,
            status: status,
            fulfillmentType: .delivery,
            date: Date(timeIntervalSince1970: 900),
            items: [],
            itemsSubtotal: 85,
            deliveryFee: 10,
            totalPrice: 95,
            paymentMethod: paymentMethod,
            paymentStatus: paymentStatus,
            paymentExpiresAt: expiresAt
        )
        return OrderDetailViewModel(
            getOrderDetailUseCase: OrderDetailUseCaseStub(entity: entity),
            now: { Date(timeIntervalSince1970: 1_000) }
        )
    }

    @MainActor
    private func waitForLoadedState(in viewModel: OrderDetailViewModel) async throws {
        try await waitUntil {
            if case .loaded = viewModel.detailState { return true }
            return false
        }
    }

    @MainActor
    private func orderCount(in state: OrderHistoryViewState) -> Int {
        guard case let .loaded(sections) = state else { return 0 }
        return sections.flatMap(\.orders).count
    }

    @MainActor
    private func waitUntil(
        timeoutIterations: Int = 100,
        condition: @escaping () -> Bool
    ) async throws {
        for _ in 0..<timeoutIterations {
            if condition() { return }
            try await Task.sleep(for: .milliseconds(10))
        }
        XCTFail("Timed out waiting for asynchronous order state")
    }
}

private final class OrderDetailUseCaseStub: GetOrderDetailUseCaseProtocol {
    private let entity: OrderDetailEntity

    init(entity: OrderDetailEntity) {
        self.entity = entity
    }

    func execute(id: Int) async throws -> OrderDetailEntity {
        _ = id
        return entity
    }
}

private actor OrdersUseCaseStub: LoadOrdersUseCaseProtocol {
    private let pages: [Int: PagedResult<OrderEntity>]
    private(set) var requestedPages: [Int] = []

    init(pages: [Int: PagedResult<OrderEntity>]) {
        self.pages = pages
    }

    func execute(filter: OrdersFilter, page: Int, size: Int) async throws -> PagedResult<OrderEntity> {
        _ = filter
        _ = size
        requestedPages.append(page)
        guard let result = pages[page] else {
            throw OrdersUseCaseStubError.missingPage(page)
        }
        return result
    }
}

private enum OrdersUseCaseStubError: Error {
    case missingPage(Int)
}
