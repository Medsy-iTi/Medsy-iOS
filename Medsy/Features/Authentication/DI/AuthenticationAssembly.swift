//
//  AuthenticationAssembly.swift
//  Medsy
//

struct AuthenticationAssembly: ModuleAssembly {
    func register(in container: DIContainer) {
        container.register(AuthenticationFactory.self) { _ in
            AuthenticationFactory()
        }
    }
}
