//
//  OrderRouteServices.swift
//  Medsy
//
//  Created by Ahmed Elkady on 12/08/2026.
//

import Foundation

@MainActor
protocol OrderCurrentLocationProviding: AnyObject {
    func currentLocation() async throws -> OrderCoordinatePresentation
}

@MainActor
protocol OrderRouteProviding: AnyObject {
    func route(
        from source: OrderCoordinatePresentation,
        to destination: OrderCoordinatePresentation
    ) async throws -> [OrderCoordinatePresentation]
}

@MainActor
protocol OrderDirectionsOpening: AnyObject {
    func openDirections(to destination: OrderCoordinatePresentation, name: String)
}
