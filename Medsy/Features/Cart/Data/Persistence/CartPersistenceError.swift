//
//  CartPersistenceError.swift
//  Medsy
//
//  Created by Ehab Salah on 13/08/2026.
//

import Foundation

enum CartPersistenceError: LocalizedError {
    case invalidPrescriptionSource

    var errorDescription: String? {
        "Unable to read the saved prescription source."
    }
}
