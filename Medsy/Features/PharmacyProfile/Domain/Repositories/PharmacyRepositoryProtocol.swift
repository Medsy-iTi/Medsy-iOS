//
//  PharmacyRepositoryProtocol.swift
//  Medsy
//
//  Created by Antoneos Philip on 21/07/2026.
//

import Foundation

protocol PharmacyRepositoryProtocol {
    func fetchPharmacy(id: Int) async throws -> Pharmacy
}
