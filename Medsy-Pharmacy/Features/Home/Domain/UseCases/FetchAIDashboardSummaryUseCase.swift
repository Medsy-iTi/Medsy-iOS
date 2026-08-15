//
//  FetchAIDashboardSummaryUseCase.swift
//  Medsy-Pharmacy
//

protocol FetchAIDashboardSummaryUseCaseProtocol: Sendable {
    func execute(period: PharmacyDashboardPeriod) async throws -> AIDashboardSummary
}

struct FetchAIDashboardSummaryUseCase: FetchAIDashboardSummaryUseCaseProtocol {
    private let repository: PharmacyDashboardRepositoryProtocol

    init(repository: PharmacyDashboardRepositoryProtocol) {
        self.repository = repository
    }

    func execute(period: PharmacyDashboardPeriod) async throws -> AIDashboardSummary {
        try await repository.fetchAIDashboardSummary(period: period)
    }
}
