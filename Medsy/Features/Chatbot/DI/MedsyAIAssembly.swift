//
//  MedsyAIAssembly.swift
//  Medsy
//
//  Created by ITI_JETS on 23/07/2026.
//


import Foundation

struct ChatbotAssembly: ModuleAssembly {
    func register(in container: DIContainer) {
        
        // MARK: - Repositories
        container.register(ChatRepositoryProtocol.self) { _ in
            ChatRepository()
        }

        // MARK: - Use Cases
        container.register(SendMessageUseCaseProtocol.self) { c in
            SendMessageUseCase(
                repository: c.resolve(ChatRepositoryProtocol.self)
            )
        }

        container.register(FetchChatHistoryUseCaseProtocol.self) { c in
            FetchChatHistoryUseCase(
                repository: c.resolve(ChatRepositoryProtocol.self)
            )
        }

        // MARK: - ViewModels
        container.register(ChatViewModel.self) { c in
            MainActor.assumeIsolated {
                ChatViewModel(
                    sendMessageUseCase: c.resolve(SendMessageUseCaseProtocol.self),
                    fetchChatHistoryUseCase: c.resolve(FetchChatHistoryUseCaseProtocol.self)
                )
            }
        }
    }
}
