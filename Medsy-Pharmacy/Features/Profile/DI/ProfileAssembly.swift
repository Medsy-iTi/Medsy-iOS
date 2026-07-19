//
//  ProfileAssembly.swift
//  Medsy
//
//  Created by Shahudaa on 18/07/2026.
//


import Foundation

struct ProfileAssembly: PharmacyModuleAssembly {
	func register(in container: PharmacyDIContainer) {
		container.register(ProfileRepositoryProtocol.self) { container in
			ProfileRepository(
                networkService: container.resolve(NetworkServiceProtocol.self),
                tokenStore: container.resolve(TokenStoreProtocol.self)
            )
		}
	}
}
