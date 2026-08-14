//
//  MedsyAIAssembly.swift
//  Medsy
//

import Foundation

struct ChatbotAssembly: ModuleAssembly {
    let reminderStore: ReminderStore?

    init(reminderStore: ReminderStore? = nil) {
        self.reminderStore = reminderStore
    }

    func register(in container: DIContainer) {

        // ── Legacy catalog chatbot (kept for build compatibility) ──
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

        // Old ChatViewModel (kept for build compatibility)
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

        // ── New AI Chat contract (shared types from SharedCore) ──
        container.register(AIChatRemoteDataSourceProtocol.self) { c in
            AIChatRemoteDataSource(
                networkService: c.resolve(NetworkServiceProtocol.self),
                aiKey: Constants.aiKey
            )
        }

        container.register(AIChatRepositoryProtocol.self) { c in
            AIChatRepositoryImpl(
                remoteDataSource: c.resolve(AIChatRemoteDataSourceProtocol.self)
            )
        }

        container.register(SendAiChatTextMessageUseCaseProtocol.self) { c in
            SendAiChatTextMessageUseCase(
                repository: c.resolve(AIChatRepositoryProtocol.self)
            )
        }

        container.register(SendAiChatImageMessageUseCaseProtocol.self) { c in
            SendAiChatImageMessageUseCase(
                repository: c.resolve(AIChatRepositoryProtocol.self)
            )
        }

        container.register(LoadAiChatHistoryUseCaseProtocol.self) { c in
            LoadAiChatHistoryUseCase(
                repository: c.resolve(AIChatRepositoryProtocol.self)
            )
        }

        container.register(StartNewAiChatUseCaseProtocol.self) { c in
            StartNewAiChatUseCase(
                repository: c.resolve(AIChatRepositoryProtocol.self)
            )
        }

        container.register(AiChatViewModel.self) { [reminderStore] c in
            MainActor.assumeIsolated {
                AiChatViewModel(
                    sendTextUseCase:     c.resolve(SendAiChatTextMessageUseCaseProtocol.self),
                    sendImageUseCase:    c.resolve(SendAiChatImageMessageUseCaseProtocol.self),
                    loadHistoryUseCase:  c.resolve(LoadAiChatHistoryUseCaseProtocol.self),
                    startNewChatUseCase: c.resolve(StartNewAiChatUseCaseProtocol.self),
                    session:             AIChatSessionDataSource(),
                    speechRecognizer:    AiChatSpeechRecognizer(),
                    reminderStore:       reminderStore,
                    reminderScheduler:   .shared
                )
            }
        }
    }
}
