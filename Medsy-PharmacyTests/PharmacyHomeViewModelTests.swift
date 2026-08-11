//
//  PharmacyHomeViewModelTests.swift
//  Medsy-PharmacyTests
//

import Alamofire
import XCTest
@testable import Medsy_Pharmacy

final class PharmacyDashboardContractTests: XCTestCase {
    func testEndpointUsesAuthenticatedDashboardContractAndDisablesLogging() {
        let endpoint = PharmacyDashboardEndpoint.fetch(period: .lastWeek)

        XCTAssertEqual(endpoint.path, "pharmacies/dashboard")
        XCTAssertEqual(endpoint.method, .get)
        XCTAssertEqual(endpoint.queryParameters?["period"] as? String, "LAST_WEEK")
        XCTAssertTrue(endpoint.requiresAuthentication)
        XCTAssertFalse(endpoint.allowsResponseLogging)
        XCTAssertNil(endpoint.body)
    }

    func testResponseDecodesAndMapsEveryDashboardSection() throws {
        let json = """
        {
          "success": true,
          "message": "ok",
          "data": {
            "totalRevenue": 1250.75,
            "totalOrders": 12,
            "requestsReceived": 18,
            "offersCreated": 15,
            "topSellingProducts": [{
              "productId": 4,
              "productName": "Pain Relief",
              "imageUrl": "/images/product.png",
              "totalQuantitySold": 9,
              "totalRevenue": 720.5
            }],
            "recentOrders": [{
              "id": 88,
              "customerId": 7,
              "customerName": "Customer",
              "customerNotes": "Leave at reception",
              "deliveryAddress": "10 Health Street",
              "phoneNumber": "01000000000",
              "prescriptionUrl": "/prescriptions/88.png",
              "pharmacyId": 42,
              "pharmacyName": "Live Pharmacy",
              "pharmacyAddress": "20 Pharmacy Street",
              "pharmacyPhone": "0200000000",
              "pharmacistId": 3,
              "pharmacistName": "Pharmacist",
              "offerId": 19,
              "subTotal": 100,
              "deliveryFee": 10,
              "total": 110,
              "deliveryLatitude": 30.1,
              "deliveryLongitude": 31.2,
              "createdAt": "2026-07-30",
              "items": [{
                "id": 1,
                "productId": 4,
                "productName": "Pain Relief",
                "imageUrl": "https://cdn.example.com/product.png",
                "quantity": 2,
                "unitPrice": 50,
                "totalPrice": 100
              }]
            }]
          }
        }
        """

        let envelope = try JSONDecoder().decode(
            PharmacyDashboardEnvelopeDTO.self,
            from: Data(json.utf8)
        )
        let dto = try XCTUnwrap(envelope.data)
        let dashboard = PharmacyDashboardMapper.map(dto)

        XCTAssertEqual(dashboard.totalRevenue, 1250.75)
        XCTAssertEqual(dashboard.totalOrders, 12)
        XCTAssertEqual(dashboard.requestsReceived, 18)
        XCTAssertEqual(dashboard.offersCreated, 15)

        let product = try XCTUnwrap(dashboard.topSellingProducts.first)
        XCTAssertEqual(product.productId, 4)
        XCTAssertEqual(product.productName, "Pain Relief")
        XCTAssertEqual(
            product.imageUrl,
            PharmacyConfiguration.imageBaseURL + "images/product.png"
        )
        XCTAssertEqual(product.totalQuantitySold, 9)
        XCTAssertEqual(product.totalRevenue, 720.5)

        let order = try XCTUnwrap(dashboard.recentOrders.first)
        XCTAssertEqual(order.id, 88)
        XCTAssertEqual(order.customerId, 7)
        XCTAssertEqual(order.customerNotes, "Leave at reception")
        XCTAssertEqual(order.deliveryFee, 10)
        XCTAssertEqual(order.total, 110)
        XCTAssertNotNil(order.createdAt)
        XCTAssertEqual(order.items.first?.productName, "Pain Relief")
        XCTAssertEqual(order.items.first?.imageUrl, "https://cdn.example.com/product.png")
    }

    func testMapperSupportsISO8601DatesAndRejectsInvalidDates() {
        XCTAssertNotNil(PharmacyDashboardMapper.parseDate("2026-07-30T09:15:10Z"))
        XCTAssertNotNil(PharmacyDashboardMapper.parseDate("2026-07-30T09:15:10.123Z"))
        XCTAssertNil(PharmacyDashboardMapper.parseDate("not-a-date"))
    }

    func testRemoteDataSourceRejectsMissingDashboardData() async {
        let service = DashboardNetworkService(
            response: PharmacyDashboardEnvelopeDTO(
                success: true,
                message: "Missing dashboard",
                data: nil
            )
        )
        let dataSource = PharmacyDashboardRemoteDataSource(networkService: service)

        do {
            _ = try await dataSource.fetchDashboard(period: .lastMonth)
            XCTFail("Expected missing data to fail")
        } catch {
            guard case NetworkError.validationError(let message) = error else {
                return XCTFail("Expected validation error, got \(error)")
            }
            XCTAssertEqual(message, "Missing dashboard")
        }
    }
}

@MainActor
final class PharmacyHomeViewModelTests: XCTestCase {
    func testRefreshLoadsProfileAndDefaultLastMonthDashboard() async {
        let session = makeSession()
        let useCase = HomeDashboardUseCase { period in
            XCTAssertEqual(period, .lastMonth)
            return makeDashboard()
        }
        let viewModel = makeViewModel(
            session: session,
            dashboardUseCase: useCase
        )

        await viewModel.refresh()

        XCTAssertEqual(viewModel.selectedPeriod, .lastMonth)
        XCTAssertEqual(viewModel.dashboardState, .loaded)
        XCTAssertEqual(viewModel.dashboard, makeDashboard())
        XCTAssertEqual(viewModel.metrics.count, 4)
        XCTAssertEqual(viewModel.topSellingProducts.map(\.id), [4])
        XCTAssertEqual(viewModel.recentOrders.map(\.id), [88])
        XCTAssertEqual(useCase.receivedPeriods, [.lastMonth])
        XCTAssertEqual(session.currentPharmacyId, 42)
        XCTAssertEqual(session.pharmacyName, "Live Pharmacy")
    }

    func testPeriodSelectionReloadsOnlyDashboard() async {
        let session = makeSession()
        let profileUseCase = HomeProfileUseCase(result: .success(makeProfile()))
        let dashboardUseCase = HomeDashboardUseCase { _ in makeDashboard() }
        let viewModel = PharmacyHomeViewModel(
            getProfileUseCase: profileUseCase,
            fetchDashboardUseCase: dashboardUseCase,
            sendHeartbeatUseCase: HomeHeartbeatUseCase(),
            sessionSettings: session
        )

        await viewModel.refresh()
        await viewModel.selectPeriod(.lastYear)

        XCTAssertEqual(viewModel.selectedPeriod, .lastYear)
        XCTAssertEqual(dashboardUseCase.receivedPeriods, [.lastMonth, .lastYear])
        XCTAssertEqual(profileUseCase.callCount, 1)
    }

    func testNonAdminProfileShowsRestrictedStateWithoutDashboardRequest() async {
        let dashboardUseCase = HomeDashboardUseCase { _ in makeDashboard() }
        let viewModel = makeViewModel(
            profileResult: .success(makeProfile(isAdmin: false)),
            dashboardUseCase: dashboardUseCase
        )

        await viewModel.refresh()

        XCTAssertEqual(viewModel.dashboardState, .restricted)
        XCTAssertNil(viewModel.dashboard)
        XCTAssertTrue(dashboardUseCase.receivedPeriods.isEmpty)
    }

    func testProfileFailureStillAttemptsDashboardWhenRoleIsUnknown() async {
        let dashboardUseCase = HomeDashboardUseCase { _ in makeDashboard() }
        let viewModel = makeViewModel(
            profileResult: .failure(HomeTestError.failed),
            dashboardUseCase: dashboardUseCase
        )

        await viewModel.refresh()

        guard case .failed = viewModel.profileState else {
            return XCTFail("Expected profile failure")
        }
        XCTAssertEqual(viewModel.dashboardState, .loaded)
        XCTAssertEqual(dashboardUseCase.receivedPeriods, [.lastMonth])
    }

    func testDashboardFailureShowsRetryableFailure() async {
        let viewModel = makeViewModel(
            dashboardUseCase: HomeDashboardUseCase { _ in
                throw HomeTestError.failed
            }
        )

        await viewModel.refresh()

        guard case .failed = viewModel.dashboardState else {
            return XCTFail("Expected dashboard failure")
        }
        XCTAssertNil(viewModel.dashboard)
    }

    func testSuccessfulEmptyArraysKeepLoadedStateAndIndependentEmptySections() async {
        let emptyDashboard = PharmacyDashboard(
            totalRevenue: 0,
            totalOrders: 0,
            requestsReceived: 0,
            offersCreated: 0,
            topSellingProducts: [],
            recentOrders: []
        )
        let viewModel = makeViewModel(
            dashboardUseCase: HomeDashboardUseCase { _ in emptyDashboard }
        )

        await viewModel.refresh()

        XCTAssertEqual(viewModel.dashboardState, .loaded)
        XCTAssertTrue(viewModel.topSellingProducts.isEmpty)
        XCTAssertTrue(viewModel.recentOrders.isEmpty)
        XCTAssertEqual(viewModel.metrics.count, 4)
    }

    func testSlowerPreviousPeriodResponseCannotOverwriteLatestSelection() async {
        let useCase = HomeDashboardUseCase { period in
            if period == .lastDay {
                try await Task.sleep(for: .milliseconds(120))
                return makeDashboard(totalOrders: 1)
            }
            try await Task.sleep(for: .milliseconds(10))
            return makeDashboard(totalOrders: 7)
        }
        let viewModel = makeViewModel(dashboardUseCase: useCase)

        let first = Task { await viewModel.selectPeriod(.lastDay) }
        try? await Task.sleep(for: .milliseconds(15))
        let second = Task { await viewModel.selectPeriod(.lastWeek) }

        await first.value
        await second.value

        XCTAssertEqual(viewModel.selectedPeriod, .lastWeek)
        XCTAssertEqual(viewModel.dashboard?.totalOrders, 7)
        XCTAssertEqual(viewModel.dashboardState, .loaded)
    }

    func testDutyStatusPersistsAndClearRemovesAllSessionValues() {
        let suiteName = "PharmacyHomeSessionTests.\(UUID().uuidString)"
        let defaults = UserDefaults(suiteName: suiteName)!
        defer { defaults.removePersistentDomain(forName: suiteName) }

        let session = PharmacySessionSettings(defaults: defaults)
        session.updatePharmacy(id: 12, name: "Name", address: "Address")
        session.updateDutyStatus(true)

        XCTAssertTrue(PharmacySessionSettings(defaults: defaults).isOnDuty)

        session.clear()

        XCTAssertNil(session.currentPharmacyId)
        XCTAssertNil(session.pharmacyName)
        XCTAssertNil(session.pharmacyAddress)
        XCTAssertFalse(session.isOnDuty)
        XCTAssertFalse(PharmacySessionSettings(defaults: defaults).isOnDuty)
    }

    func testRefreshSynchronizesDutyStatusFromCurrentPharmacistPresence() async {
        let session = makeSession()
        session.updateDutyStatus(false)
        let heartbeatUseCase = HomeHeartbeatUseCase(
            result: .success(PresenceEntity(lastHeartbeatAt: "2026-08-05T18:00:00Z", onDuty: true))
        )
        let viewModel = makeViewModel(
            session: session,
            dashboardUseCase: HomeDashboardUseCase { _ in makeDashboard() },
            heartbeatUseCase: heartbeatUseCase
        )

        await viewModel.refresh()

        XCTAssertTrue(session.isOnDuty)
        XCTAssertEqual(heartbeatUseCase.callCount, 1)
    }

    func testPresenceFailureKeepsCachedDutyStatus() async {
        let session = makeSession()
        session.updateDutyStatus(true)
        let viewModel = makeViewModel(
            session: session,
            dashboardUseCase: HomeDashboardUseCase { _ in makeDashboard() },
            heartbeatUseCase: HomeHeartbeatUseCase(result: .failure(HomeTestError.failed))
        )

        await viewModel.refresh()

        XCTAssertTrue(session.isOnDuty)
        XCTAssertEqual(viewModel.dashboardState, .loaded)
    }

    private func makeViewModel(
        session: PharmacySessionSettings? = nil,
        profileResult: Result<PharmacyProfile, Error> = .success(makeProfile()),
        dashboardUseCase: HomeDashboardUseCase,
        heartbeatUseCase: HomeHeartbeatUseCase = HomeHeartbeatUseCase()
    ) -> PharmacyHomeViewModel {
        PharmacyHomeViewModel(
            getProfileUseCase: HomeProfileUseCase(result: profileResult),
            fetchDashboardUseCase: dashboardUseCase,
            sendHeartbeatUseCase: heartbeatUseCase,
            sessionSettings: session ?? makeSession()
        )
    }

    private func makeSession() -> PharmacySessionSettings {
        PharmacySessionSettings(
            defaults: UserDefaults(suiteName: "PharmacyHomeTests.\(UUID().uuidString)")!
        )
    }
}

private enum HomeTestError: Error {
    case failed
}

private final class HomeProfileUseCase: GetPharmacyProfileUseCaseProtocol {
    let result: Result<PharmacyProfile, Error>
    private(set) var callCount = 0

    init(result: Result<PharmacyProfile, Error>) {
        self.result = result
    }

    func execute() async throws -> PharmacyProfile {
        callCount += 1
        return try result.get()
    }
}

private final class HomeDashboardUseCase: FetchPharmacyDashboardUseCaseProtocol {
    private let action: (PharmacyDashboardPeriod) async throws -> PharmacyDashboard
    private(set) var receivedPeriods: [PharmacyDashboardPeriod] = []

    init(action: @escaping (PharmacyDashboardPeriod) async throws -> PharmacyDashboard) {
        self.action = action
    }

    func execute(period: PharmacyDashboardPeriod) async throws -> PharmacyDashboard {
        receivedPeriods.append(period)
        return try await action(period)
    }
}

private final class HomeHeartbeatUseCase: SendHeartbeatUseCaseProtocol {
    let result: Result<PresenceEntity, Error>
    private(set) var callCount = 0

    init(
        result: Result<PresenceEntity, Error> = .success(
            PresenceEntity(lastHeartbeatAt: "", onDuty: false)
        )
    ) {
        self.result = result
    }

    func execute() async throws -> PresenceEntity {
        callCount += 1
        return try result.get()
    }
}

private struct DashboardNetworkService: NetworkServiceProtocol {
    let response: PharmacyDashboardEnvelopeDTO

    func request<T: Decodable>(endpoint: ApiEndpoint) async throws -> T {
        guard let typedResponse = response as? T else {
            throw NetworkError.decodingFailed
        }
        return typedResponse
    }

    func requestData(endpoint: ApiEndpoint) async throws -> Data {
        throw NetworkError.decodingFailed
    }
}

private func makeProfile(isAdmin: Bool = true) -> PharmacyProfile {
    PharmacyProfile(
        id: "1",
        firstName: "Mona",
        lastName: "Ali",
        email: "mona@example.com",
        phoneNumber: "01000000000",
        pharmacyId: 42,
        isPharmacyAdmin: isAdmin,
        homeAddress: nil,
        dateOfBirth: nil,
        pharmacyName: "Live Pharmacy",
        pharmacyAddress: "10 Health Street",
        pharmacyPhoneNumber: nil,
        pharmacyMembers: []
    )
}

private func makeDashboard(totalOrders: Int = 12) -> PharmacyDashboard {
    PharmacyDashboard(
        totalRevenue: 1_250.75,
        totalOrders: totalOrders,
        requestsReceived: 18,
        offersCreated: 15,
        topSellingProducts: [
            PharmacyDashboardTopSellingProduct(
                productId: 4,
                productName: "Pain Relief",
                imageUrl: "https://cdn.example.com/product.png",
                totalQuantitySold: 9,
                totalRevenue: 720.5
            )
        ],
        recentOrders: [
            PharmacyDashboardRecentOrder(
                id: 88,
                customerId: 7,
                customerName: "Customer",
                customerNotes: "Leave at reception",
                deliveryAddress: "10 Health Street",
                phoneNumber: "01000000000",
                prescriptionUrl: nil,
                pharmacyId: 42,
                pharmacyName: "Live Pharmacy",
                pharmacyAddress: "20 Pharmacy Street",
                pharmacyPhone: "0200000000",
                pharmacistId: 3,
                pharmacistName: "Pharmacist",
                offerId: 19,
                subTotal: 100,
                deliveryFee: 10,
                total: 110,
                deliveryLatitude: 30.1,
                deliveryLongitude: 31.2,
                createdAt: Date(timeIntervalSince1970: 1_700_000_000),
                items: [
                    PharmacyDashboardRecentOrderItem(
                        id: 1,
                        productId: 4,
                        productName: "Pain Relief",
                        imageUrl: nil,
                        quantity: 2,
                        unitPrice: 50,
                        totalPrice: 100
                    )
                ]
            )
        ]
    )
}
