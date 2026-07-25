//
//  MedsyAICoordinator.swift
//  Medsy
//
//  Created by ITI_JETS on 23/07/2026.
//

import Observation
import SwiftUI


@MainActor
@Observable
final class ChatbotCoordinator {
    var path = NavigationPath()

    func push(_ route: ChatbotRoute) {
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
