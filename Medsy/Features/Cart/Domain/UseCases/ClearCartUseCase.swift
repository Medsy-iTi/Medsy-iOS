//
//  ClearCartUseCase.swift
//  Medsy
//
//  Created by Ahmed Elkady on 19/07/2026.
//

protocol ClearCartUseCaseProtocol {
    func execute() async throws
    func clearAfterCompletedRequest() async throws
}

extension ClearCartUseCaseProtocol {
    func clearAfterCompletedRequest() async throws {
        try await execute()
    }
}

final class ClearCartUseCase: ClearCartUseCaseProtocol {
    private let cartRepository: CartRepositoryProtocol
    private let prescriptionRepository: CartPrescriptionRepositoryProtocol

    init(
        cartRepository: CartRepositoryProtocol,
        prescriptionRepository: CartPrescriptionRepositoryProtocol
    ) {
        self.cartRepository = cartRepository
        self.prescriptionRepository = prescriptionRepository
    }

    func execute() async throws {
        try await cartRepository.clearCart()
        try await prescriptionRepository.clearPrescriptions()
    }

    func clearAfterCompletedRequest() async throws {
        var cleanupError: Error?

        do {
            try await prescriptionRepository.clearPrescriptions()
        } catch {
            cleanupError = error
        }

        do {
            try await cartRepository.clearCachedCart()
        } catch {
            cleanupError = cleanupError ?? error
        }

        if let cleanupError {
            throw cleanupError
        }
    }
}
