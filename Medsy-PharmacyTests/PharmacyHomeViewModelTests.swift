//
//  PharmacyHomeViewModelTests.swift
//  Medsy-PharmacyTests
//

import XCTest
@testable import Medsy_Pharmacy

@MainActor
final class PharmacyHomeViewModelTests: XCTestCase {
    func testRefreshLoadsProfileAndFirstFourOrdersInServerOrder() async {
        let session = makeSession()
        let orders = (1...6).map {
            makeOrder(id: $0, customerName: "Customer \($0)", address: "Address \($0)")
        }
        let fetch = HomeOrdersUseCase(result: .success(
            PharmacyOrdersPage(orders: orders, pageNumber: 0, totalPages: 2, isLastPage: false)
        ))
        let viewModel = makeViewModel(session: session, fetch: fetch)

        await viewModel.refresh()

        XCTAssertEqual(session.pharmacyName, "Live Pharmacy")
        XCTAssertEqual(session.pharmacyAddress, "10 Health Street")
        XCTAssertEqual(viewModel.recentOrders.map(\.id), ["1", "2", "3", "4"])
        XCTAssertEqual(fetch.receivedPage, 0)
        XCTAssertEqual(fetch.receivedSize, 4)
        XCTAssertEqual(viewModel.ordersState, .loaded)
    }

    func testEmptyOrdersUsesEmptyState() async {
        let session = makeSession()
        let fetch = HomeOrdersUseCase(result: .success(
            PharmacyOrdersPage(orders: [], pageNumber: 0, totalPages: 1, isLastPage: true)
        ))
        let viewModel = makeViewModel(session: session, fetch: fetch)

        await viewModel.refresh()

        XCTAssertEqual(viewModel.ordersState, .empty)
        XCTAssertTrue(viewModel.recentOrders.isEmpty)
    }

    func testProfileFailureDoesNotHideSuccessfulOrdersFromCachedPharmacy() async {
        let session = makeSession()
        session.currentPharmacyId = 42
        let order = makeOrder(id: 9)
        let fetch = HomeOrdersUseCase(result: .success(
            PharmacyOrdersPage(orders: [order], pageNumber: 0, totalPages: 1, isLastPage: true)
        ))
        let viewModel = PharmacyHomeViewModel(
            getProfileUseCase: HomeProfileUseCase(result: .failure(HomeTestError.failed)),
            fetchOrdersUseCase: fetch,
            identityProvider: session,
            sessionSettings: session
        )

        await viewModel.refresh()

        guard case .failed = viewModel.profileState else {
            return XCTFail("Expected profile failure")
        }
        XCTAssertEqual(viewModel.ordersState, .loaded)
        XCTAssertEqual(viewModel.recentOrders.first?.sourceOrder, order)
    }

    func testOrdersFailureDoesNotDiscardSuccessfulProfile() async {
        let session = makeSession()
        let viewModel = makeViewModel(
            session: session,
            fetch: HomeOrdersUseCase(result: .failure(HomeTestError.failed))
        )

        await viewModel.refresh()

        XCTAssertEqual(viewModel.profileState, .loaded)
        guard case .failed = viewModel.ordersState else {
            return XCTFail("Expected orders failure")
        }
        XCTAssertEqual(session.pharmacyName, "Live Pharmacy")
    }

    func testAllAPIStatusesMapToSupportedHomeStatuses() {
        let pendingApprovalId = 987_654
        PharmacySubmittedOffersStore.shared.insert(pendingApprovalId)

        let cases: [(PharmacyOrderAPIStatus, Int, PharmacyOrderStatus)] = [
            (.pending, 987_653, .new),
            (.pending, pendingApprovalId, .pendingApproval),
            (.accepted, 2, .preparing),
            (.preparing, 3, .preparing),
            (.outForDelivery, 4, .preparing),
            (.delivered, 5, .delivered),
            (.completed, 6, .completed),
            (.cancelled, 7, .expired),
            (.expired, 8, .expired),
            (.unknown("NEW_SERVER_VALUE"), 9, .expired)
        ]

        for (apiStatus, id, expected) in cases {
            XCTAssertEqual(
                PharmacyHomeOrder(order: makeOrder(id: id, status: apiStatus)).status,
                expected
            )
        }
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

    private func makeViewModel(
        session: PharmacySessionSettings,
        fetch: HomeOrdersUseCase
    ) -> PharmacyHomeViewModel {
        PharmacyHomeViewModel(
            getProfileUseCase: HomeProfileUseCase(result: .success(makeProfile())),
            fetchOrdersUseCase: fetch,
            identityProvider: session,
            sessionSettings: session
        )
    }

    private func makeSession() -> PharmacySessionSettings {
        PharmacySessionSettings(
            defaults: UserDefaults(suiteName: "PharmacyHomeTests.\(UUID().uuidString)")!
        )
    }

    private func makeProfile() -> PharmacyProfile {
        PharmacyProfile(
            id: "1",
            firstName: "Mona",
            lastName: "Ali",
            email: "mona@example.com",
            phoneNumber: "01000000000",
            pharmacyId: 42,
            isPharmacyAdmin: true,
            homeAddress: nil,
            dateOfBirth: nil,
            pharmacyName: "Live Pharmacy",
            pharmacyAddress: "10 Health Street",
            pharmacyPhoneNumber: nil,
            pharmacyMembers: []
        )
    }

    private func makeOrder(
        id: Int,
        status: PharmacyOrderAPIStatus = .pending,
        customerName: String? = "Customer",
        address: String = "Address"
    ) -> PharmacyOrder {
        PharmacyOrder(
            id: id,
            userId: id + 100,
            pharmacyId: 42,
            totalPrice: 100,
            deliveryCoordinate: (30, 31),
            status: status,
            date: Date().addingTimeInterval(-300),
            items: [],
            deliveryAddress: address,
            prescriptionUrl: nil,
            customerName: customerName,
            customerPhone: nil,
            notes: nil
        )
    }
}

private enum HomeTestError: Error {
    case failed
}

private struct HomeProfileUseCase: GetPharmacyProfileUseCaseProtocol {
    let result: Result<PharmacyProfile, Error>

    func execute() async throws -> PharmacyProfile {
        try result.get()
    }
}

private final class HomeOrdersUseCase: FetchPharmacyOrdersUseCaseProtocol {
    let result: Result<PharmacyOrdersPage, Error>
    private(set) var receivedPage: Int?
    private(set) var receivedSize: Int?

    init(result: Result<PharmacyOrdersPage, Error>) {
        self.result = result
    }

    func execute(pharmacyId: Int, page: Int, size: Int) async throws -> PharmacyOrdersPage {
        receivedPage = page
        receivedSize = size
        return try result.get()
    }
}
