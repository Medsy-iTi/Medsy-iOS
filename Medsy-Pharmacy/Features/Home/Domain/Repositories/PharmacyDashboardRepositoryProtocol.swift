//
//  PharmacyDashboardRepositoryProtocol.swift
//  Medsy-Pharmacy
//

protocol PharmacyDashboardRepositoryProtocol {
    func fetchDashboard(period: PharmacyDashboardPeriod) async throws -> PharmacyDashboard
}
