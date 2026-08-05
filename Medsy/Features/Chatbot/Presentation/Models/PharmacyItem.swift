//
//  PharmacyItem.swift
//  Medsy
//
//  Created by ITI_JETS on 23/07/2026.
//

import Foundation


struct PharmacyItem: Identifiable {
    let id = UUID()
    let name: String
    let isOpen24h: Bool
    let distance: String
    let closingTime: String
}
