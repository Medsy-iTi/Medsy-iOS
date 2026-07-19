//
//  LoadCartUseCase.swift
//  Medsy
//
//  Created by Ahmed Elkady on 19/07/2026.
//

protocol LoadCartUseCaseProtocol {
    func cached() async throws -> Cart
    func refresh() async throws -> Cart
}

final class LoadCartUseCase: LoadCartUseCaseProtocol {
    private let cartRepository: CartRepositoryProtocol
    private let prescriptionRepository: CartPrescriptionRepositoryProtocol

    init(
        cartRepository: CartRepositoryProtocol,
        prescriptionRepository: CartPrescriptionRepositoryProtocol
    ) {
        self.cartRepository = cartRepository
        self.prescriptionRepository = prescriptionRepository
    }

    func cached() async throws -> Cart {
        async let cart = cartRepository.fetchCachedCart()
        async let prescriptions = prescriptionRepository.fetchPrescriptions()
        return try await cart.withPrescriptions(prescriptions)
    }

    func refresh() async throws -> Cart {
        async let cart = cartRepository.fetchCart()
        async let prescriptions = prescriptionRepository.fetchPrescriptions()
        return try await cart.withPrescriptions(prescriptions)
    }
}
