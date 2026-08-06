//
//  PharmacyChatbotAssembly.swift
//  Medsy-Pharmacy

import Foundation

struct PharmacyChatbotAssembly: PharmacyModuleAssembly {
    func register(in container: PharmacyDIContainer) {
        
        container.register(AIChatRemoteDataSourceProtocol.self) { c in
            AIChatRemoteDataSource(
                networkService: c.resolve(NetworkServiceProtocol.self),
                aiKey: PharmacyConfiguration.aiKey
            )
        }
        
        container.register(AIChatRepositoryProtocol.self) { c in
            AIChatRepositoryImpl(
                remoteDataSource: c.resolve(AIChatRemoteDataSourceProtocol.self)
            )
        }
        
        container.register(SendAiChatTextMessageUseCaseProtocol.self) { c in
            SendAiChatTextMessageUseCase(repository: c.resolve(AIChatRepositoryProtocol.self))
        }
        
        container.register(SendAiChatImageMessageUseCaseProtocol.self) { c in
            SendAiChatImageMessageUseCase(repository: c.resolve(AIChatRepositoryProtocol.self))
        }
        
        container.register(LoadAiChatHistoryUseCaseProtocol.self) { c in
            LoadAiChatHistoryUseCase(repository: c.resolve(AIChatRepositoryProtocol.self))
        }
        
        container.register(StartNewAiChatUseCaseProtocol.self) { c in
            StartNewAiChatUseCase(repository: c.resolve(AIChatRepositoryProtocol.self))
        }
        
        container.register(PharmacyAiChatViewModelFactory.self) { c in
            DefaultPharmacyAiChatViewModelFactory(container: c)
        }
    }
}

private struct DefaultPharmacyAiChatViewModelFactory: PharmacyAiChatViewModelFactory {
    private let container: PharmacyDIContainer
    
    init(container: PharmacyDIContainer) {
        self.container = container
    }
    
    @MainActor
    func makeViewModel() -> PharmacyAiChatViewModel {
        PharmacyAiChatViewModel(
            sendTextUseCase: container.resolve(SendAiChatTextMessageUseCaseProtocol.self),
            sendImageUseCase: container.resolve(SendAiChatImageMessageUseCaseProtocol.self),
            loadHistoryUseCase: container.resolve(LoadAiChatHistoryUseCaseProtocol.self),
            startNewChatUseCase: container.resolve(StartNewAiChatUseCaseProtocol.self),
            session: AIChatSessionDataSource()
        )
    }
}
