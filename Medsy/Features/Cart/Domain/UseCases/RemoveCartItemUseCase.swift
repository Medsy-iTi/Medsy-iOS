//
//  RemoveCartItemUseCase.swift
//  Medsy
//
//  Created by Ahmed Elkady on 19/07/2026.
//

protocol RemoveCartItemUseCaseProtocol {
    func execute(itemID: Int64) async throws -> Cart
}

final class RemoveCartItemUseCase: RemoveCartItemUseCaseProtocol {
    private let cartRepository: CartRepositoryProtocol
    private let prescriptionRepository: CartPrescriptionRepositoryProtocol

    init(
        cartRepository: CartRepositoryProtocol,
        prescriptionRepository: CartPrescriptionRepositoryProtocol
    ) {
        self.cartRepository = cartRepository
        self.prescriptionRepository = prescriptionRepository
    }

    func execute(itemID: Int64) async throws -> Cart {
        async let cart = cartRepository.removeItem(id: itemID)
        async let prescriptions = prescriptionRepository.fetchPrescriptions()
        return try await cart.withPrescriptions(prescriptions)
    }
}
