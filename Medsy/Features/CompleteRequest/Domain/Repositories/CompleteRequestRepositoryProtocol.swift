//
//  CompleteRequestRepositoryProtocol.swift
//  Medsy
//
//  Created by Ehab Salah on 24/07/2026.
//

protocol CompleteRequestRepositoryProtocol {
    func submit(input: SubmitCompleteRequestInput) async throws -> SubmittedMedicineRequest
}
