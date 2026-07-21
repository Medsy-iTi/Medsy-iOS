//
//  UpdateCartItemQuantityUseCase.swift
//  Medsy
//
//  Created by Ahmed Elkady on 19/07/2026.
//

protocol UpdateCartItemQuantityUseCaseProtocol {
    func execute(itemID: Int64, quantity: Int) async throws -> Cart
}

final class UpdateCartItemQuantityUseCase: UpdateCartItemQuantityUseCaseProtocol {
    private let cartRepository: CartRepositoryProtocol
    private let prescriptionRepository: CartPrescriptionRepositoryProtocol

    init(
        cartRepository: CartRepositoryProtocol,
        prescriptionRepository: CartPrescriptionRepositoryProtocol
    ) {
        self.cartRepository = cartRepository
        self.prescriptionRepository = prescriptionRepository
    }

    func execute(itemID: Int64, quantity: Int) async throws -> Cart {
        async let cart = cartRepository.updateItem(id: itemID, quantity: quantity)
        async let prescriptions = prescriptionRepository.fetchPrescriptions()
        return try await cart.withPrescriptions(prescriptions)
    }
}
