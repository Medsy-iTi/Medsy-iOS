//
//  FavoriteFeatureTests.swift
//  MedsyTests
//
//  Created by Ehab Salah on 13/08/2026.
//

import SwiftData
import XCTest
@testable import Medsy

final class FavoritePersistenceTests: XCTestCase {
    func testFactoryCreatesIsolatedInMemoryContainers() throws {
        let schema = Schema([FavoriteMedicineModel.self])
        let first = try SwiftDataFactory.shared.makeContainer(for: schema, configuration: .inMemory())
        let second = try SwiftDataFactory.shared.makeContainer(for: schema, configuration: .inMemory())
        let firstContext = ModelContext(first)
        firstContext.insert(FavoriteMedicineModel(accountIdentifier: "account-a", record: record(id: 1)))
        try firstContext.save()

        XCTAssertEqual(try firstContext.fetch(FetchDescriptor<FavoriteMedicineModel>()).count, 1)
        XCTAssertTrue(try ModelContext(second).fetch(FetchDescriptor<FavoriteMedicineModel>()).isEmpty)
    }

    func testLocalDataSourceUpsertsOrdersScopesAndRemovesFavorites() async throws {
        let dataSource = try FavoriteLocalDataSource(configuration: .inMemory())
        try await dataSource.upsert(record(id: 1, name: "Older", createdAt: Date(timeIntervalSince1970: 10)), accountID: "account-a")
        try await dataSource.upsert(record(id: 2, name: "Newer", createdAt: Date(timeIntervalSince1970: 20)), accountID: "account-a")
        try await dataSource.upsert(record(id: 1, name: "Updated"), accountID: "account-a")
        try await dataSource.upsert(record(id: 2, name: "Other Account"), accountID: "account-b")

        let accountA = try await dataSource.fetchAll(accountID: "account-a")
        XCTAssertEqual(accountA.count, 2)
        XCTAssertEqual(accountA.first?.productID, 1)
        XCTAssertEqual(accountA.first?.name, "Updated")
        let accountAContainsProduct2 = try await dataSource.contains(productID: 2, accountID: "account-a")
        XCTAssertTrue(accountAContainsProduct2)

        try await dataSource.remove(productID: 2, accountID: "account-a")
        let accountAStillContainsProduct2 = try await dataSource.contains(productID: 2, accountID: "account-a")
        let accountBContainsProduct2 = try await dataSource.contains(productID: 2, accountID: "account-b")
        XCTAssertFalse(accountAStillContainsProduct2)
        XCTAssertTrue(accountBContainsProduct2)
    }

    private func record(id: Int, name: String = "Medicine", createdAt: Date = Date()) -> FavoriteMedicineRecord {
        FavoriteMedicineRecord(
            productID: id, name: name, arabicName: "دواء", scientificName: "Ingredient",
            price: 25, imageURL: nil, categoryID: 3, categoryName: "Pain Relief",
            company: "Medsy", route: "Oral", createdAt: createdAt
        )
    }
}

@MainActor
final class FavoriteFeatureTests: XCTestCase {
    func testRepositoryScopesAndForwardsOperations() async throws {
        let dataSource = FavoriteLocalDataSourceSpy()
        dataSource.records = [FavoriteMedicineMapper.map(medicine(id: 7))]
        dataSource.containsResult = true
        let repository = FavoriteRepository(
            localDataSource: dataSource,
            accountScopeProvider: AccountScopeProviderStub(identifier: "patient-42")
        )

        let fetchedIDs = try await repository.fetchAll().map(\.id)
        let isFavorite = try await repository.isFavorite(productID: 7)
        XCTAssertEqual(fetchedIDs, [7])
        XCTAssertTrue(isFavorite)
        try await repository.setFavorite(medicine(id: 8), isFavorite: true)
        try await repository.setFavorite(medicine(id: 8), isFavorite: false)

        XCTAssertEqual(dataSource.fetchedAccounts, ["patient-42"])
        XCTAssertEqual(dataSource.upserted.first?.record.productID, 8)
        XCTAssertEqual(dataSource.removed.first?.productID, 8)
    }

    func testUseCasesForwardToRepository() async throws {
        let repository = FavoriteRepositorySpy()
        repository.medicines = [medicine(id: 4)]
        repository.isFavoriteResult = true

        let fetchedIDs = try await FetchFavoritesUseCase(repository: repository).execute().map(\.id)
        let isFavorite = try await IsFavoriteUseCase(repository: repository).execute(productID: 4)
        XCTAssertEqual(fetchedIDs, [4])
        XCTAssertTrue(isFavorite)
        try await SetFavoriteUseCase(repository: repository).execute(medicine(id: 4), isFavorite: false)
        XCTAssertEqual(repository.setRequests.first?.isFavorite, false)
    }

    func testViewModelLoadsContentAndEmptyStates() async {
        let fetch = FetchFavoritesUseCaseStub(result: .success([medicine(id: 1)]))
        let viewModel = makeViewModel(fetch: fetch)
        await viewModel.load()
        guard case let .loaded(products) = viewModel.state else { return XCTFail("Expected loaded") }
        XCTAssertEqual(products.map(\.id), ["1"])

        fetch.result = .success([])
        await viewModel.load()
        XCTAssertEqual(viewModel.state, .empty)
    }

    func testViewModelShowsFailureWhenLoadFails() async {
        let viewModel = makeViewModel(fetch: FetchFavoritesUseCaseStub(result: .failure(TestError.failed)))
        await viewModel.load()
        guard case .failed = viewModel.state else { return XCTFail("Expected failed") }
    }

    func testRemovalRollsBackOnPersistenceFailure() async {
        let fetch = FetchFavoritesUseCaseStub(result: .success([medicine(id: 3)]))
        let set = SetFavoriteUseCaseSpy(error: TestError.failed)
        let viewModel = makeViewModel(fetch: fetch, set: set)
        await viewModel.load()
        guard case let .loaded(products) = viewModel.state, let display = products.first else { return XCTFail("Expected loaded") }

        await viewModel.remove(display)
        guard case let .loaded(restored) = viewModel.state else { return XCTFail("Expected rollback") }
        XCTAssertEqual(restored.map(\.id), ["3"])
        XCTAssertNotNil(viewModel.persistenceErrorMessage)
    }

    func testOfflineDetailGuard() {
        let connectivity = ConnectivityStub(status: .disconnected)
        let viewModel = makeViewModel(connectivity: connectivity)
        XCTAssertNil(viewModel.detailDestination(for: "9"))
        XCTAssertTrue(viewModel.isShowingOfflineAlert)

        connectivity.status = .unknown
        XCTAssertEqual(viewModel.detailDestination(for: "9"), "9")
    }

    func testPresentationSupportsEnglishAndArabic() {
        let product = FavoriteMedicine(
            id: 2, name: "Panadol Extra 500 MG", arabicName: "بانادول إكسترا",
            scientificName: "Paracetamol", price: 30, imageURL: nil, categoryID: 1,
            categoryName: "Pain Relief", company: "GSK", route: "Oral"
        )
        let english = FavoriteMedicinePresentationMapper.map(product, isRTL: false)
        let arabic = FavoriteMedicinePresentationMapper.map(product, isRTL: true)
        XCTAssertEqual(english.title, "Panadol Extra")
        XCTAssertEqual(english.dosageInfo, "500 MG")
        XCTAssertEqual(arabic.title, "بانادول إكسترا")
    }

    func testFavoriteCountRefreshesFromPersistedFavorites() async {
        let fetch = FetchFavoritesUseCaseStub(result: .success([medicine(id: 1), medicine(id: 2)]))
        let viewModel = FavoriteCountViewModel(fetchFavoritesUseCase: fetch)

        await viewModel.refresh()

        XCTAssertEqual(viewModel.count, 2)

        fetch.result = .success([medicine(id: 2)])
        await viewModel.refresh()

        XCTAssertEqual(viewModel.count, 1)
    }

    func testFavoriteCountKeepsLastValueWhenRefreshFails() async {
        let fetch = FetchFavoritesUseCaseStub(result: .success([medicine(id: 1)]))
        let viewModel = FavoriteCountViewModel(fetchFavoritesUseCase: fetch)
        await viewModel.refresh()

        fetch.result = .failure(TestError.failed)
        await viewModel.refresh()

        XCTAssertEqual(viewModel.count, 1)
    }

    private func makeViewModel(
        fetch: FetchFavoritesUseCaseStub = FetchFavoritesUseCaseStub(result: .success([])),
        set: SetFavoriteUseCaseSpy = SetFavoriteUseCaseSpy(),
        connectivity: ConnectivityStub? = nil
    ) -> FavoriteViewModel {
        FavoriteViewModel(
            fetchFavoritesUseCase: fetch,
            setFavoriteUseCase: set,
            connectivity: connectivity ?? ConnectivityStub(status: .connected),
            languageManager: .shared
        )
    }
}

private enum TestError: Error { case failed }

private func medicine(id: Int) -> FavoriteMedicine {
    FavoriteMedicine(
        id: id, name: "Medicine \(id) 10 MG", arabicName: "دواء \(id)",
        scientificName: "Ingredient", price: 20, imageURL: nil, categoryID: 1,
        categoryName: "Category", company: "Company", route: "Oral",
        createdAt: Date(timeIntervalSince1970: TimeInterval(id))
    )
}

private final class AccountScopeProviderStub: AccountScopeProviderProtocol {
    let identifier: String
    init(identifier: String) { self.identifier = identifier }
    func currentIdentifier() throws -> String { identifier }
}

private final class FavoriteLocalDataSourceSpy: FavoriteLocalDataSourceProtocol {
    var records: [FavoriteMedicineRecord] = []
    var containsResult = false
    var fetchedAccounts: [String] = []
    var upserted: [(record: FavoriteMedicineRecord, accountID: String)] = []
    var removed: [(productID: Int, accountID: String)] = []

    func fetchAll(accountID: String) async throws -> [FavoriteMedicineRecord] {
        fetchedAccounts.append(accountID); return records
    }
    func contains(productID: Int, accountID: String) async throws -> Bool { containsResult }
    func upsert(_ record: FavoriteMedicineRecord, accountID: String) async throws { upserted.append((record, accountID)) }
    func remove(productID: Int, accountID: String) async throws { removed.append((productID, accountID)) }
}

private final class FavoriteRepositorySpy: FavoriteRepositoryProtocol {
    var medicines: [FavoriteMedicine] = []
    var isFavoriteResult = false
    var setRequests: [(medicine: FavoriteMedicine, isFavorite: Bool)] = []
    func fetchAll() async throws -> [FavoriteMedicine] { medicines }
    func isFavorite(productID: Int) async throws -> Bool { isFavoriteResult }
    func setFavorite(_ medicine: FavoriteMedicine, isFavorite: Bool) async throws { setRequests.append((medicine, isFavorite)) }
}

private final class FetchFavoritesUseCaseStub: FetchFavoritesUseCaseProtocol {
    var result: Result<[FavoriteMedicine], Error>
    init(result: Result<[FavoriteMedicine], Error>) { self.result = result }
    func execute() async throws -> [FavoriteMedicine] { try result.get() }
}

private final class SetFavoriteUseCaseSpy: SetFavoriteUseCaseProtocol {
    var requests: [(medicine: FavoriteMedicine, isFavorite: Bool)] = []
    let error: Error?
    init(error: Error? = nil) { self.error = error }
    func execute(_ medicine: FavoriteMedicine, isFavorite: Bool) async throws {
        requests.append((medicine, isFavorite)); if let error { throw error }
    }
}

@MainActor
private final class ConnectivityStub: NetworkConnectivityProviding {
    var status: NetworkConnectivityStatus
    init(status: NetworkConnectivityStatus) { self.status = status }
}
