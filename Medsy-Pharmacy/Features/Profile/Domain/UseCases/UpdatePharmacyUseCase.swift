//
//  UpdatePharmacyUseCase.swift
//  Medsy-Pharmacy
//

import Foundation

protocol UpdatePharmacyUseCaseProtocol {
    func execute(id: Int, name: String?, address: String?, phoneNumber: String?) async throws
}

final class UpdatePharmacyUseCase: UpdatePharmacyUseCaseProtocol {
    private let repository: ProfileRepositoryProtocol

    init(repository: ProfileRepositoryProtocol) {
        self.repository = repository
    }

    func execute(id: Int, name: String?, address: String?, phoneNumber: String?) async throws {
        try await repository.updatePharmacy(id: id, name: name, address: address, phoneNumber: phoneNumber)
    }
}
