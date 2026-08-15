//
//  PharmacyDashboardRepository.swift
//  Medsy-Pharmacy
//

struct PharmacyDashboardRepository: PharmacyDashboardRepositoryProtocol {
    private let remoteDataSource: PharmacyDashboardRemoteDataSourceProtocol

    init(remoteDataSource: PharmacyDashboardRemoteDataSourceProtocol) {
        self.remoteDataSource = remoteDataSource
    }

    func fetchDashboard(period: PharmacyDashboardPeriod) async throws -> PharmacyDashboard {
        let dto = try await remoteDataSource.fetchDashboard(period: period)
        return PharmacyDashboardMapper.map(dto)
    }

    func fetchAIDashboardSummary(period: PharmacyDashboardPeriod) async throws -> AIDashboardSummary {
        let dto = try await remoteDataSource.fetchAIDashboardSummary(period: period)
        return PharmacyDashboardMapper.map(dto)
    }
}
