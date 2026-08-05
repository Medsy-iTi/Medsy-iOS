//
//  Category.swift
//  Medsy
//
//  Created by Antoneos Philip on 17/07/2026.
//

import Foundation

struct Category: Identifiable, Equatable {
    let id: Int
    let name: String

    var displayName: String {
        name.lowercased().capitalized
    }
}
