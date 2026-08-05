
//
//  MedsyAIAssembly.swift
//  Medsy
//
//  Created by ITI_JETS on 23/07/2026.
//


import Foundation
struct ChatbotAssembly: ModuleAssembly {

    func register(in container: DIContainer) {


        container.register(CatalogAskDataSourceProtocol.self) { c in
            CatalogAskDataSource(
                networkService: c.resolve(NetworkServiceProtocol.self)
            )
        }


        container.register(ChatRepositoryProtocol.self) { c in
            ChatRepositoryImpl(
                dataSource: c.resolve(CatalogAskDataSourceProtocol.self)
            )
        }


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

        container.register(ChatViewModel.self) { c in
            MainActor.assumeIsolated {
                ChatViewModel(
                    sendMessageUseCase:       c.resolve(SendMessageUseCaseProtocol.self),
                    fetchChatHistoryUseCase:  c.resolve(FetchChatHistoryUseCaseProtocol.self),
                    addCartItemUseCase:       c.resolve(AddCartItemUseCaseProtocol.self),
                    languageManager:          c.resolve(LanguageManager.self)
                )
            }
        }
    }
}
