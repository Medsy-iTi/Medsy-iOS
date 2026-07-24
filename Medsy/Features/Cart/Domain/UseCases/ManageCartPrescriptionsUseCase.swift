//
//  ManageCartPrescriptionsUseCase.swift
//  Medsy
//
//  Created by Ahmed Elkady on 19/07/2026.
//

import Foundation

protocol ManageCartPrescriptionsUseCaseProtocol {
    func add(_ prescription: CartPrescription) async throws -> [CartPrescription]
    func replace(id: UUID, with prescription: CartPrescription) async throws -> [CartPrescription]
    func remove(id: UUID) async throws -> [CartPrescription]
}

final class ManageCartPrescriptionsUseCase: ManageCartPrescriptionsUseCaseProtocol {
    private let repository: CartPrescriptionRepositoryProtocol

    init(repository: CartPrescriptionRepositoryProtocol) {
        self.repository = repository
    }

    func add(_ prescription: CartPrescription) async throws -> [CartPrescription] {
        try await repository.addPrescription(prescription)
        return try await repository.fetchPrescriptions()
    }

    func replace(id: UUID, with prescription: CartPrescription) async throws -> [CartPrescription] {
        try await repository.replacePrescription(id: id, with: prescription)
        return try await repository.fetchPrescriptions()
    }

    func remove(id: UUID) async throws -> [CartPrescription] {
        try await repository.removePrescription(id: id)
        return try await repository.fetchPrescriptions()
    }
}
