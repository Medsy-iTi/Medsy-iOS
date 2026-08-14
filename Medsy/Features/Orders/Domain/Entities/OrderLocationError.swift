//
//  OrderLocationError.swift
//  Medsy
//
//  Created by Ahmed Elkady on 12/08/2026.
//

import Foundation

enum OrderLocationError: Error, Equatable {
    case permissionDenied
    case locationUnavailable
    case routeUnavailable
}
