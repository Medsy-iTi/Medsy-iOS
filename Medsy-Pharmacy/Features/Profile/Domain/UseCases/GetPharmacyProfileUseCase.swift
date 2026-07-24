//
//  GetPharmacyProfileUseCaseProtocol.swift
//  Medsy
//
//  Created by Shahudaa on 18/07/2026.
//


import Foundation

protocol GetPharmacyProfileUseCaseProtocol {
    func execute() async throws -> PharmacyProfile
}

struct GetPharmacyProfileUseCase: GetPharmacyProfileUseCaseProtocol {
    let repository: ProfileRepositoryProtocol

    func execute() async throws -> PharmacyProfile {
        try await repository.fetchProfile()
    }
}
