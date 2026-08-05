//
//  FetchPharmacyDashboardUseCase.swift
//  Medsy-Pharmacy
//

protocol FetchPharmacyDashboardUseCaseProtocol {
    func execute(period: PharmacyDashboardPeriod) async throws -> PharmacyDashboard
}

struct FetchPharmacyDashboardUseCase: FetchPharmacyDashboardUseCaseProtocol {
    private let repository: PharmacyDashboardRepositoryProtocol

    init(repository: PharmacyDashboardRepositoryProtocol) {
        self.repository = repository
    }

    func execute(period: PharmacyDashboardPeriod) async throws -> PharmacyDashboard {
        try await repository.fetchDashboard(period: period)
    }
}
