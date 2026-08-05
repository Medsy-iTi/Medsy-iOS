//
//  PharmacyDashboardRemoteDataSource.swift
//  Medsy-Pharmacy
//

protocol PharmacyDashboardRemoteDataSourceProtocol {
    func fetchDashboard(period: PharmacyDashboardPeriod) async throws -> PharmacyDashboardDTO
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
}
