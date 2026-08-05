//  PharmacyRequestDetailsRepositoryProtocol.swift
//  Medsy-Pharmacy
//
//  Created by Antoneos Philip on 23/07/2026.
//

import Foundation

protocol PharmacyRequestDetailsRepositoryProtocol {
    func fetchRequestDetails(requestId: Int) async throws -> PharmacyRequestDetailsEntity
}
