//
//  AuthenticationAssembly.swift
//  Medsy
//
//  Created by Ehab Salah on 16/07/2026.
//

struct AuthenticationAssembly: ModuleAssembly {
    func register(in container: DIContainer) {
        container.register(AuthenticationFactory.self) { _ in
            AuthenticationFactory()
        }
    }
}
