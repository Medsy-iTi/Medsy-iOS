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

    func testMasterOrdersAndNestedPharmaciesAreMapped() throws {
        let data = Data(
            """
            {
              "success": true,
              "message": "Orders retrieved successfully",
              "data": {
                "content": [
                  {
                    "id": 7,
                    "requestId": 41,
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
                              "strength": "500 mg",
                              "packSize": "20 tablets",
                              "form": "Tablet",
                              "price": 50,
                              "scientificName": "Medicine ingredient",
                              "company": "Medsy Labs",
                              "route": "Oral",
                              "description": "Pain relief",
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
        XCTAssertEqual(result.items.map(\.id), [7])
        XCTAssertEqual(result.items.first?.pharmacyNames, ["Medsy Pharmacy"])
        XCTAssertEqual(result.items.first?.itemImageURLs, ["https://example.com/medicine.png"])
        XCTAssertEqual(detail.pharmacies.first?.id, 71)
        XCTAssertEqual(detail.pharmacies.first?.coordinate?.latitude, 30)
        XCTAssertEqual(detail.items.first?.productName, "Received medicine")
        XCTAssertEqual(detail.items.first?.product?.strength, "500 mg")
        XCTAssertEqual(detail.items.first?.imageURL, "https://example.com/medicine.png")
        XCTAssertEqual(detail.itemsSubtotal, 85)
        XCTAssertEqual(detail.totalPrice, 95)
        XCTAssertEqual(detail.paymentMethod, .card)
        XCTAssertEqual(detail.paymentStatus, .pending)
    }

    func testMasterOrdersEndpointsUsePaginationAndExplicitLanguage() {
        let listEndpoint = OrdersEndpoint.fetchOrders(page: 1, size: 20, language: "ar")
        let detailEndpoint = OrdersEndpoint.fetchOrderDetail(id: 7, language: "ar")
        let parameters = listEndpoint.queryParameters

        XCTAssertEqual(listEndpoint.path, "masterorders")
        XCTAssertEqual(parameters?["page"] as? Int, 1)
        XCTAssertEqual(parameters?["size"] as? Int, 20)
        XCTAssertEqual(parameters?["lang"] as? String, "ar")
        XCTAssertNil(parameters?["sort"])
        XCTAssertNil(parameters?["status"])
        XCTAssertNil(parameters?["dateFrom"])
        XCTAssertNil(parameters?["dateTo"])
        XCTAssertEqual(detailEndpoint.path, "masterorders/7")
        XCTAssertEqual(detailEndpoint.queryParameters?["lang"] as? String, "ar")
    }

    func testBackendOrderStatusesMapToKnownCases() {
        XCTAssertEqual(OrderStatus(rawValue: "PENDING_PAYMENT").rawValue, "PENDING_PAYMENT")
        XCTAssertEqual(OrderStatus(rawValue: "PREPARING").rawValue, "PREPARING")
        XCTAssertEqual(OrderStatus(rawValue: "READY_FOR_PICKUP").rawValue, "READY_FOR_PICKUP")
        XCTAssertEqual(OrderStatus(rawValue: "READY_FOR_DELIVERY").rawValue, "READY_FOR_DELIVERY")
        XCTAssertEqual(OrderStatus(rawValue: "OUT_FOR_DELIVERY").rawValue, "OUT_FOR_DELIVERY")
    }

    func testDomainDetailMapsPharmacyGroupsAndUnavailableProduct() throws {
        let item = OrderDetailItemEntity(
            id: 11,
            productId: nil,
            productName: "Unavailable medicine",
            originalProductName: nil,
            quantity: 2,
            unitPrice: 42.5,
            imageURL: nil
        )
        let detail = OrderDetailEntity(
            id: 7,
            orderNumber: 7,
            pharmacyName: "Medsy Pharmacy",
            pharmacyId: 3,
            status: .pendingPayment,
            fulfillmentType: .delivery,
            date: .now,
            items: [item],
            itemsSubtotal: 85,
            deliveryFee: 10,
            totalPrice: 95,
            requestID: 41,
            pharmacies: [
                OrderPharmacyEntity(
                    id: 71,
                    pharmacyId: 3,
                    pharmacyName: "Medsy Pharmacy",
                    coordinate: OrderCoordinateEntity(latitude: 30, longitude: 31),
                    items: [item]
                )
            ],
            paymentMethod: .card,
            paymentStatus: .pending
        )

        let presentation = OrderEntityMapper.mapDetail(detail)

        XCTAssertEqual(presentation.pharmacies.first?.id, 71)
        XCTAssertEqual(presentation.pharmacies.first?.name, "Medsy Pharmacy")
        XCTAssertEqual(presentation.pharmacies.first?.coordinate?.latitude, 30)
        XCTAssertNil(presentation.pharmacies.first?.items.first?.productId)
        XCTAssertEqual(presentation.requestID, 41)
        XCTAssertEqual(presentation.paymentMethod, .card)
        XCTAssertEqual(presentation.paymentStatus, .pending)
    }

    func testCashPickupOrderAcceptsNullPaymentStatusAndHidesDeliveryFee() throws {
        let dto = try decodeMasterOrder(fulfillmentMethod: "PICKUP")

        let detail = OrderMapper.mapToDetailEntity(dto)

        XCTAssertEqual(detail.fulfillmentType, .pickup)
        XCTAssertNil(detail.deliveryFee)
        XCTAssertEqual(detail.paymentMethod, .cash)
        XCTAssertNil(detail.paymentStatus)
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
    func testHistoryFiltersCachedOrdersWithoutRequestingAgain() async throws {
        let useCase = OrdersUseCaseStub(
            pages: [
                0: PagedResult(
                    items: [
                        orderEntity(id: 1, status: .delivered),
                        orderEntity(id: 2, status: .cancelled)
                    ],
                    page: 0,
                    size: 20,
                    totalElements: 3,
                    totalPages: 2,
                    isLast: false
                ),
                1: PagedResult(
                    items: [orderEntity(id: 3, status: .cancelled)],
                    page: 1,
                    size: 20,
                    totalElements: 3,
                    totalPages: 2,
                    isLast: true
                )
            ]
        )
        let viewModel = OrderHistoryViewModel(loadOrdersUseCase: useCase)

        viewModel.handle(.load)
        try await waitUntil { self.orderCount(in: viewModel.historyState) == 2 }

        var filters = ActiveOrderFilters.default
        filters.statusFilter = .cancelled
        viewModel.handle(.applyFilters(filters))

        XCTAssertEqual(orderIDs(in: viewModel.historyState), [2])
        var requestedPages = await useCase.requestedPages
        var requestedFilters = await useCase.requestedFilters
        XCTAssertEqual(requestedPages, [0])
        XCTAssertEqual(requestedFilters, [.empty])

        viewModel.handle(.loadNextPage)
        try await waitUntil { self.orderCount(in: viewModel.historyState) == 2 }

        XCTAssertEqual(orderIDs(in: viewModel.historyState), [2, 3])
        requestedPages = await useCase.requestedPages
        requestedFilters = await useCase.requestedFilters
        XCTAssertEqual(requestedPages, [0, 1])
        XCTAssertEqual(requestedFilters, [.empty, .empty])
    }

    @MainActor
    func testDetailRoutesToSelectedPharmacyAndOpensDirections() async throws {
        let source = OrderCoordinatePresentation(latitude: 30.0400, longitude: 31.2250)
        let locationProvider = OrderLocationProviderStub(result: .success(source))
        let routeProvider = OrderRouteProviderStub()
        let directionsOpener = OrderDirectionsOpenerSpy()
        let viewModel = OrderDetailViewModel(
            state: .loaded(.mock),
            locationProvider: locationProvider,
            routeProvider: routeProvider,
            directionsOpener: directionsOpener
        )

        try await waitUntil {
            guard case .ready = viewModel.routeState else { return false }
            return viewModel.selectedPharmacyID == 71
        }

        viewModel.handle(.selectPharmacy(72))
        try await waitUntil {
            guard case .ready(let points) = viewModel.routeState else { return false }
            return viewModel.selectedPharmacyID == 72
                && points.last == OrderCoordinatePresentation(latitude: 30.0520, longitude: 31.2300)
        }

        viewModel.handle(.openDirections)

        XCTAssertEqual(routeProvider.destinations.count, 2)
        XCTAssertEqual(directionsOpener.openedName, "Al Shifa Pharmacy")
        XCTAssertEqual(
            directionsOpener.openedDestination,
            OrderCoordinatePresentation(latitude: 30.0520, longitude: 31.2300)
        )
    }

    @MainActor
    func testDetailShowsPermissionDeniedWhenLocationAccessIsDenied() async throws {
        let viewModel = OrderDetailViewModel(
            state: .loaded(.mock),
            locationProvider: OrderLocationProviderStub(result: .failure(.permissionDenied)),
            routeProvider: OrderRouteProviderStub()
        )

        try await waitUntil { viewModel.routeState == .permissionDenied }
    }

    private func decodeMasterOrder(fulfillmentMethod: String) throws -> MasterOrderDTO {
        let json =
            """
            {
              "id": 7,
              "requestId": 41,
              "orderResponses": [
                {
                  "offerId": 71,
                  "pharmacyId": 3,
                  "pharmacyName": "Snapshot Pharmacy",
                  "latitude": 30,
                  "longitude": 31,
                  "items": []
                }
              ],
              "paymentMethod": "CASH",
              "paymentStatus": null,
              "fulfillmentMethod": "\(fulfillmentMethod)",
              "deliveryFee": 10,
              "totalPrice": 85,
              "orderStatus": "PREPARING",
              "paymentExpiresAt": null,
              "paidAt": null
            }
            """

        return try JSONDecoder().decode(MasterOrderDTO.self, from: Data(json.utf8))
    }

    private func orderEntity(id: Int, status: OrderStatus = .delivered) -> OrderEntity {
        OrderEntity(
            id: id,
            orderNumber: id,
            pharmacyName: "Pharmacy",
            status: status,
            fulfillmentType: .pickup,
            date: Date(timeIntervalSince1970: TimeInterval(id)),
            totalPrice: 10,
            itemCount: 1,
            itemImageURLs: []
        )
    }

    @MainActor
    private func orderCount(in state: OrderHistoryViewState) -> Int {
        guard case let .loaded(sections) = state else { return 0 }
        return sections.flatMap(\.orders).count
    }

    @MainActor
    private func orderIDs(in state: OrderHistoryViewState) -> [Int] {
        guard case let .loaded(sections) = state else { return [] }
        return sections.flatMap(\.orders).map(\.id)
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

private actor OrdersUseCaseStub: LoadOrdersUseCaseProtocol {
    private let pages: [Int: PagedResult<OrderEntity>]
    private(set) var requestedPages: [Int] = []
    private(set) var requestedFilters: [OrdersFilter] = []

    init(pages: [Int: PagedResult<OrderEntity>]) {
        self.pages = pages
    }

    func execute(filter: OrdersFilter, page: Int, size: Int) async throws -> PagedResult<OrderEntity> {
        _ = size
        requestedPages.append(page)
        requestedFilters.append(filter)
        guard let result = pages[page] else {
            throw OrdersUseCaseStubError.missingPage(page)
        }
        return result
    }
}

private enum OrdersUseCaseStubError: Error {
    case missingPage(Int)
}

@MainActor
private final class OrderLocationProviderStub: OrderCurrentLocationProviding {
    let result: Result<OrderCoordinatePresentation, OrderLocationError>

    init(result: Result<OrderCoordinatePresentation, OrderLocationError>) {
        self.result = result
    }

    func currentLocation() async throws -> OrderCoordinatePresentation {
        try result.get()
    }
}

@MainActor
private final class OrderRouteProviderStub: OrderRouteProviding {
    private(set) var destinations: [OrderCoordinatePresentation] = []

    func route(
        from source: OrderCoordinatePresentation,
        to destination: OrderCoordinatePresentation
    ) async throws -> [OrderCoordinatePresentation] {
        destinations.append(destination)
        return [source, destination]
    }
}

@MainActor
private final class OrderDirectionsOpenerSpy: OrderDirectionsOpening {
    private(set) var openedDestination: OrderCoordinatePresentation?
    private(set) var openedName: String?

    func openDirections(to destination: OrderCoordinatePresentation, name: String) {
        openedDestination = destination
        openedName = name
    }
}
