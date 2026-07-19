//
//  ToggleOrderReceivingStatusUseCaseProtocol.swift
//  Medsy
//
//  Created by Shahudaa on 18/07/2026.
//


import Foundation

protocol ToggleOrderReceivingStatusUseCaseProtocol {
    @discardableResult
    func execute(isOpen: Bool) async throws -> Bool
}

struct ToggleOrderReceivingStatusUseCase: ToggleOrderReceivingStatusUseCaseProtocol {
    let repository: ProfileRepositoryProtocol

    @discardableResult
    func execute(isOpen: Bool) async throws -> Bool {
        try await repository.updateOrderReceivingStatus(isOpen: isOpen)
    }
}
