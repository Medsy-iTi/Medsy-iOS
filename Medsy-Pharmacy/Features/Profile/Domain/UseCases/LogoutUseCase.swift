//
//  LogoutUseCaseProtocol.swift
//  Medsy
//
//  Created by Shahudaa on 18/07/2026.
//
import Foundation


protocol LogoutUseCaseProtocol {
    func execute() async
}

struct LogoutUseCase: LogoutUseCaseProtocol {
    let repository: ProfileRepositoryProtocol
    let tokenStore: TokenStoreProtocol

    func execute() async {
        try? await repository.logout()
		try? tokenStore.clearTokens()
    }
}
