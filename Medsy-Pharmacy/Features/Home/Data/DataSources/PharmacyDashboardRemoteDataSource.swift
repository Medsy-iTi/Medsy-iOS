//
//  PharmacyDashboardRemoteDataSource.swift
//  Medsy-Pharmacy
//

protocol PharmacyDashboardRemoteDataSourceProtocol {
    func fetchDashboard(period: PharmacyDashboardPeriod) async throws -> PharmacyDashboardDTO
    func fetchAIDashboardSummary(period: PharmacyDashboardPeriod) async throws -> AIDashboardSummaryDTO
}

struct PharmacyDashboardRemoteDataSource: PharmacyDashboardRemoteDataSourceProtocol {
    private let networkService: NetworkServiceProtocol

    init(networkService: NetworkServiceProtocol) {
        self.networkService = networkService
    }

    func fetchDashboard(period: PharmacyDashboardPeriod) async throws -> PharmacyDashboardDTO {
        let envelope: PharmacyDashboardEnvelopeDTO = try await networkService.request(
            endpoint: PharmacyDashboardEndpoint.fetch(period: period)
        )

        guard envelope.success, let dashboard = envelope.data else {
            throw NetworkError.validationError(envelope.message)
        }
        return dashboard
    }

    func fetchAIDashboardSummary(period: PharmacyDashboardPeriod) async throws -> AIDashboardSummaryDTO {
        let envelope: AIDashboardSummaryEnvelopeDTO = try await networkService.request(
            endpoint: PharmacyDashboardEndpoint.fetchAISummary(period: period)
        )

        guard envelope.success, let summary = envelope.data else {
            throw NetworkError.validationError(envelope.message)
        }
        return summary
    }
}
