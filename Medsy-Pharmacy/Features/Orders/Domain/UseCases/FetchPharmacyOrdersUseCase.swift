//
//  FetchPharmacyOrdersUseCaseProtocol.swift
//  Medsy
//
//  Created by Shahudaa on 21/07/2026.
//



protocol FetchPharmacyOrdersUseCaseProtocol {
    func execute(pharmacyId: Int, page: Int, size: Int) async throws -> PharmacyOrdersPage
}

struct FetchPharmacyOrdersUseCase: FetchPharmacyOrdersUseCaseProtocol {
    let repository: PharmacyOrdersRepositoryProtocol

    func execute(pharmacyId: Int, page: Int, size: Int) async throws -> PharmacyOrdersPage {
        try await repository.fetchOrders(pharmacyId: pharmacyId, page: page, size: size)
    }
}
