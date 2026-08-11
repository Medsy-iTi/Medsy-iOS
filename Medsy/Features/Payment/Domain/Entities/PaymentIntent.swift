//
//  PaymentIntent.swift
//  Medsy
//
//  Created by Ahmed Elkady on 11/08/2026.
//

import Foundation

struct PaymentIntent: Equatable, Sendable {
    let id: String
    let clientSecret: String
}
