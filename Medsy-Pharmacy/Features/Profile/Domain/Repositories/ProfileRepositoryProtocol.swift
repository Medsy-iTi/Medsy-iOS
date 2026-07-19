//
//  ProfileRepositoryProtocol.swift
//  Medsy
//
//  Created by Shahudaa on 18/07/2026.
//


protocol ProfileRepositoryProtocol {
    func fetchProfile() async throws -> PharmacyProfile

    
    @discardableResult
    func updateOrderReceivingStatus(isOpen: Bool) async throws -> Bool

    func logout() async throws
}
