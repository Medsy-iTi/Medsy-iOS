//
//  ProductInfoRow.swift
//  Medsy
//  Created by Shahudaa on 15/07/2026.
//

import Foundation

struct ProductInfoRow: Identifiable {
    let id = UUID()
    let icon: String
    let label: String
    let value: String
    var valueColor: MedsyRowTint = .primary
}

enum MedsyRowTint {
    case primary
    case danger
}
