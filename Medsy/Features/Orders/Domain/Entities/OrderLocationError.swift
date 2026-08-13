//
//  OrderLocationError.swift
//  Medsy
//
//  Created by Codex on 12/08/2026.
//

import Foundation

enum OrderLocationError: Error, Equatable {
    case permissionDenied
    case locationUnavailable
    case routeUnavailable
}
