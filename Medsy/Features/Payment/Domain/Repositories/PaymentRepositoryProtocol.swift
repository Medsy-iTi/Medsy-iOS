//
//  PaymentRepositoryProtocol.swift
//  Medsy
//
//  Created by Ahmed Elkady on 11/08/2026.
//

import Foundation

protocol PaymentRepositoryProtocol {
    func fetchMasterOrderPayment(masterOrderId: Int) async throws -> MasterOrderPayment
    func createPaymentIntent(masterOrderId: Int) async throws -> PaymentIntent
}
