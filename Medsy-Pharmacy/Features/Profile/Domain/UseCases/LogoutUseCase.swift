//
//  LogoutUseCaseProtocol.swift
//  Medsy
//
//  Created by Shahudaa on 18/07/2026.
//
import Foundation


protocol LogoutUseCaseProtocol {func execute() async}

struct LogoutUseCase: LogoutUseCaseProtocol {
	let repository: ProfileRepositoryProtocol
	let tokenStore: TokenStoreProtocol
	let pharmacyIdentityProvidor: PharmacyIdentityProviding


	func execute() async {
		try? await repository.logout()
		try? tokenStore.clearTokens()
		await MainActor.run {
			pharmacyIdentityProvidor.currentPharmacyId = nil
		}
	}
}
