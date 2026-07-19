//
//  AddCartItemUseCase.swift
//  Medsy
//
//  Created by Ahmed Elkady on 19/07/2026.
//

protocol AddCartItemUseCaseProtocol {
    func execute(input: AddCartItemInput) async throws -> Cart
}

final class AddCartItemUseCase: AddCartItemUseCaseProtocol {
    private let cartRepository: CartRepositoryProtocol
    private let prescriptionRepository: CartPrescriptionRepositoryProtocol

    init(
        cartRepository: CartRepositoryProtocol,
        prescriptionRepository: CartPrescriptionRepositoryProtocol
    ) {
        self.cartRepository = cartRepository
        self.prescriptionRepository = prescriptionRepository
    }

    func execute(input: AddCartItemInput) async throws -> Cart {
        async let cart = cartRepository.addItem(input: input)
        async let prescriptions = prescriptionRepository.fetchPrescriptions()
        return try await cart.withPrescriptions(prescriptions)
    }
}
