//  PharmacyProfileState.swift
//  Medsy
//
//  Created by Antoneos Philip on 20/07/2026.

import Foundation

enum PharmacyProfileState: Equatable, Sendable {
    case idle
    case loading
    case loaded(Pharmacy)
    case error(String)
}
