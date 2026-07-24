//  PharmacyLoginRequestDTO.swift
//  Medsy-Pharmacy
//
//  Created by Antoneos Philip on 17/07/2026.
//

import Foundation

struct PharmacyLoginRequestDTO: Encodable, Equatable {
    let email: String
    let password: String

    init(input: PharmacyLoginInput) {
        self.email = input.email
        self.password = input.password
    }
}
