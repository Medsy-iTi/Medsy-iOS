//
//  AppAssembler.swift
//  Medsy
//
//  Created by Ahmed Elkady on 13/07/2026.
//

import Foundation

final class AppAssembler {


    static let shared = AppAssembler()

    let container: DIContainer = .shared

    private init() {}

    func assemble(modules: [ModuleAssembly]) {
        modules.forEach { $0.register(in: container) }
    }
}
