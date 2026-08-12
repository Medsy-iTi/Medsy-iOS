//
//  PharmacyChatCoordinator.swift
//  Medsy-Pharmacy

import Observation
import SwiftUI

@MainActor
@Observable
final class PharmacyChatCoordinator {
    var path = NavigationPath()

    func push(_ route: PharmacyChatRoute) {
        path.append(route)
    }

    func pop() {
        guard !path.isEmpty else { return }
        path.removeLast()
    }

    func popToRoot() {
        path = NavigationPath()
    }
}
