//
//  MedsyProduct.swift
//  Medsy
//
//  Created by Shahudaa on 15/07/2026.
//

import SwiftUI

struct MedsyProduct: Identifiable, Equatable {
    let id: String
    let name: String
    let subtitle: String     
    let price: Double
    let badgeText: String
    let badgeColor: Color
    var isFavorite: Bool = false
    var quantity: Int = 0
}
