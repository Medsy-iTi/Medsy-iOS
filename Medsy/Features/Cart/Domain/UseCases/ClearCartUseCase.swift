//
//  ClearCartUseCase.swift
//  Medsy
//
//  Created by Ahmed Elkady on 19/07/2026.
//

protocol ClearCartUseCaseProtocol {
    func execute() async throws
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
}
