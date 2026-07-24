//
//  CartPrescriptionRepositoryProtocol.swift
//  Medsy
//
//  Created by Ahmed Elkady on 19/07/2026.
//

import Foundation

protocol CartPrescriptionRepositoryProtocol {
    func fetchPrescriptions() async throws -> [CartPrescription]
    func addPrescription(_ prescription: CartPrescription) async throws
    func replacePrescription(id: UUID, with prescription: CartPrescription) async throws
    func removePrescription(id: UUID) async throws
    func clearPrescriptions() async throws
}
