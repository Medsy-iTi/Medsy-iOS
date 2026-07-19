//
//  CartPrescriptionRepository.swift
//  Medsy
//
//  Created by Ahmed Elkady on 19/07/2026.
//

import Foundation

final class CartPrescriptionRepository: CartPrescriptionRepositoryProtocol {
    private let localDataSource: CartLocalDataSourceProtocol

    init(localDataSource: CartLocalDataSourceProtocol) {
        self.localDataSource = localDataSource
    }

    func fetchPrescriptions() async throws -> [CartPrescription] {
        try await localDataSource.fetchPrescriptions().map(CartPrescriptionMapper.map)
    }

    func addPrescription(_ prescription: CartPrescription) async throws {
        try await localDataSource.addPrescription(CartPrescriptionMapper.map(prescription))
    }

    func replacePrescription(id: UUID, with prescription: CartPrescription) async throws {
        try await localDataSource.replacePrescription(
            id: id,
            with: CartPrescriptionMapper.map(prescription)
        )
    }

    func removePrescription(id: UUID) async throws {
        try await localDataSource.removePrescription(id: id)
    }

    func clearPrescriptions() async throws {
        try await localDataSource.clearPrescriptions()
    }
}
